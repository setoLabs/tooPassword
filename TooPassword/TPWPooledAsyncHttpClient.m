//
//  TPWWebDAVClient.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.11.13.
//
//

#import "TPWPooledAsyncHttpClient.h"
#import "NSString+TPWExtensions.h"
#import "TPWSettings.h"
#include <libkern/OSAtomic.h>

NSUInteger const kTPWWebDAVClientConnectionPoolSize = 10;
NSUInteger const kTPWWebDAVClientMaxAuthRetries = 1;
NSString *const kTPWPooledAsyncHttpClientErrorHttpStatusCodeKey = @"httpStatusCode";
NSString *const kTPWPooledAsyncHttpClientErrorDomain = @"TPWPooledAsyncHttpClientErrorDomain";
NSString *const kTPWWebDAVOptionsHeaderDAVKey = @"DAV";

#pragma mark TPWPooledAsyncHttpClientResponse

@interface TPWPooledAsyncHttpClientResponse ()
@property (nonatomic, copy) TPWPooledAsyncHttpClientCompleted completionCallback;
@property (nonatomic, copy) TPWPooledAsyncHttpClientRedirected redirectCallback;
@property (nonatomic, copy) TPWPooledAsyncHttpClientInProgress progressCallback;
@property (nonatomic, strong) NSMutableData *responseDataBuffer;
@property (nonatomic, assign) long long expectedSize;
@property (nonatomic, assign) NSUInteger cumulatedReceivedDataSize;
@end

@implementation TPWPooledAsyncHttpClientResponse

- (BOOL)isSupportingWebDAVProtocol {
	return (self.response.allHeaderFields[kTPWWebDAVOptionsHeaderDAVKey] != nil);
}

@end

#pragma mark -
#pragma mark TPWPooledAsyncHttpClient

@interface TPWPooledAsyncHttpClient () <NSURLConnectionDelegate>
@property (atomic, assign) volatile int32_t requestTag;
@property (nonatomic, strong) NSMutableDictionary *connectionPool; // @{tag: connection}
@property (nonatomic, strong) NSMutableDictionary *scheduledRequests; // @{tag: request}
@property (nonatomic, strong) NSMutableDictionary *receivedResponses; // @{tag: webDavClientResponse}
@property (nonatomic, strong) NSMutableArray *requestQueue;
@end

@implementation TPWPooledAsyncHttpClient

- (instancetype)init {
	if (self = [super init]) {
		self.requestTag = 0;
		self.connectionPool = [NSMutableDictionary dictionaryWithCapacity:kTPWWebDAVClientConnectionPoolSize];
		self.scheduledRequests = [NSMutableDictionary dictionary];
		self.receivedResponses = [NSMutableDictionary dictionary];
		self.requestQueue = [NSMutableArray array];
	}
	return self;
}

- (NSNumber*)makeRequest:(NSURLRequest*)request downloadToPath:(NSString*)destinationPath onRedirect:(TPWPooledAsyncHttpClientRedirected)redirectCallback onCompletion:(TPWPooledAsyncHttpClientCompleted)completionCallback onProgress:(TPWPooledAsyncHttpClientInProgress)progressCallback {
	NSParameterAssert(request);
	NSParameterAssert(completionCallback);
	NSNumber *tag = @(OSAtomicIncrement32(&_requestTag));
	
	// prepare response:
	TPWPooledAsyncHttpClientResponse *response = [[TPWPooledAsyncHttpClientResponse alloc] init];
	response.request = request;
	response.responseDataPath = destinationPath;
	response.completionCallback = completionCallback;
	response.redirectCallback = redirectCallback;
	response.progressCallback = progressCallback;
	self.receivedResponses[tag] = response;
	
	// schedule request:
	self.scheduledRequests[tag] = request;
	[self.requestQueue addObject:tag];
	
	// try starting immediately:
	[self tryToStartNextRequest];
	
	return tag;
}

- (void)cancelRequest:(NSNumber*)tag {
	// cancel one:
	[self.requestQueue removeObject:tag];
	[self.connectionPool[tag] cancel];
	[self.connectionPool removeObjectForKey:tag];
	[self.scheduledRequests removeObjectForKey:tag];
	[self.receivedResponses removeObjectForKey:tag];
	
	// start one:
	[self tryToStartNextRequest];
}

- (void)cancelAllRequest {
	[self.requestQueue removeAllObjects];
	[[self.connectionPool allValues] makeObjectsPerformSelector:@selector(cancel)];
	[self.connectionPool removeAllObjects];
	[self.scheduledRequests removeAllObjects];
	[self.receivedResponses removeAllObjects];
}

#pragma mark connection stuff

- (void)tryToStartNextRequest {
	if ([self.connectionPool count] < kTPWWebDAVClientConnectionPoolSize && [self.requestQueue count] > 0) {
		// dequeue next request:
		NSNumber *tag = [self.requestQueue objectAtIndex:0];
		NSURLRequest *req = self.scheduledRequests[tag];
		[self.requestQueue removeObject:tag];
		[self.scheduledRequests removeObjectForKey:tag];
		
		// start request:
		NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:req delegate:self startImmediately:NO];
		[conn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
		self.connectionPool[tag] = conn;
		[conn start];
	}
}

- (NSNumber*)tagOfConnection:(NSURLConnection*)conn {
	NSSet *tags = [self.connectionPool keysOfEntriesPassingTest:^BOOL(id key, id obj, BOOL *stop) {
		BOOL found = (obj == conn);
		*stop = found;
		return found;
	}];
	return tags.anyObject;
}

#pragma mark NSURLConnectionDelegate

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
	return ![protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] || [TPWSettings webDAVShouldTrustAllSSL];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if (challenge.previousFailureCount >= kTPWWebDAVClientMaxAuthRetries) {
		[challenge.sender cancelAuthenticationChallenge:challenge];
	} else {
		NSURLCredential *credential = nil;
		if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
			credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
		} else {
			credential = [NSURLCredential credentialWithUser:self.username password:self.password persistence:NSURLCredentialPersistenceForSession];
		}
		[challenge.sender useCredential:credential forAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	NSNumber *tag = [self tagOfConnection:connection];
	TPWPooledAsyncHttpClientResponse *clientResponse = self.receivedResponses[tag];
	
	NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"error.http.connectionFailed", @"Generic NSURLErrorDomain Error")};
	NSError *myError = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorConnectionFailed userInfo:userInfo];
	clientResponse.completionCallback(tag, nil, myError);
	
	[self tryToStartNextRequest];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
	NSNumber *tag = [self tagOfConnection:connection];
	TPWPooledAsyncHttpClientResponse *clientResponse = self.receivedResponses[tag];
	
	if (clientResponse.redirectCallback && redirectResponse) {
		clientResponse.redirectCallback(tag, request.URL);
	}
	
	return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSNumber *tag = [self tagOfConnection:connection];
	TPWPooledAsyncHttpClientResponse *clientResponse = self.receivedResponses[tag];
	
	if ([response isKindOfClass:NSHTTPURLResponse.class]) {
		clientResponse.response = (NSHTTPURLResponse *)response;
		if (clientResponse.response.statusCode >= 200 && clientResponse.response.statusCode < 300) {
			if (clientResponse.response.textEncodingName == nil) {
				clientResponse.responseEncoding = 0;
			} else {
				CFStringEncoding responseEncoding = CFStringConvertIANACharSetNameToEncoding((__bridge CFStringRef)clientResponse.response.textEncodingName);
				clientResponse.responseEncoding = responseEncoding == kCFStringEncodingInvalidId ? 0 : CFStringConvertEncodingToNSStringEncoding(responseEncoding);
			}
			long long expectedSize = clientResponse.response.expectedContentLength == NSURLResponseUnknownLength ? 0 : clientResponse.response.expectedContentLength;
			clientResponse.expectedSize = expectedSize;
			clientResponse.responseDataBuffer = [NSMutableData dataWithCapacity:(NSUInteger)expectedSize];
		} else if (clientResponse.response.statusCode == 404) {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"error.http.notFound", @"TPWPooledAsyncHttpClientErrorNotFound")};
			NSError *error = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorNotFound userInfo:userInfo];
			clientResponse.completionCallback(tag, nil, error);
		} else if (clientResponse.response.statusCode == 401 || clientResponse.response.statusCode == 403) {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"error.http.authFailed", @"TPWPooledAsyncHttpClientErrorAuthFailed")};
			NSError *error = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorAuthFailed userInfo:userInfo];
			clientResponse.completionCallback(tag, nil, error);
		} else {
			NSDictionary *userInfo = @{NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedString(@"error.http.httpStatusCode", @"TPWPooledAsyncHttpClientErrorOther"), clientResponse.response.statusCode],
									   kTPWPooledAsyncHttpClientErrorHttpStatusCodeKey: @(clientResponse.response.statusCode)};
			NSError *error = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorOther userInfo:userInfo];
			clientResponse.completionCallback(tag, nil, error);
		}
	} else {
		NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"error.http.unsupportedProtocol", @"TPWPooledAsyncHttpClientErrorUnsupportedProtocol")};
		NSError *error = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorUnsupportedProtocol userInfo:userInfo];
		clientResponse.completionCallback(tag, nil, error);
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSNumber *tag = [self tagOfConnection:connection];
	TPWPooledAsyncHttpClientResponse *clientResponse = self.receivedResponses[tag];
	[clientResponse.responseDataBuffer appendData:data];
	if (clientResponse.progressCallback && clientResponse.expectedSize != 0) {
		clientResponse.cumulatedReceivedDataSize += data.length;
		clientResponse.progressCallback((CGFloat)clientResponse.cumulatedReceivedDataSize / (CGFloat)clientResponse.expectedSize);
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSNumber *tag = [self tagOfConnection:connection];
	TPWPooledAsyncHttpClientResponse *response = self.receivedResponses[tag];
	
	DLog(@"finished loading - %zd: %@", response.response.statusCode, [[NSString alloc] initWithData:response.responseDataBuffer encoding:NSUTF8StringEncoding]);
	
	// how to handle buffered data:
	if (response.responseDataBuffer.length > 0) {
		if (response.responseDataPath) {
			[response.responseDataBuffer writeToFile:response.responseDataPath atomically:YES];
		} else {
			response.responseData = response.responseDataBuffer;
		}
	}
	
	// callback:
	response.completionCallback(tag, response, nil);
	
	// cleanup:
	response.responseDataBuffer = nil;
	[self.connectionPool removeObjectForKey:tag];
	
	// proceed:
	[self tryToStartNextRequest];
}

@end
