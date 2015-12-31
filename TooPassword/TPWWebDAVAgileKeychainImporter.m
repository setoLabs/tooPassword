//
//  TPWWebDAVAgileKeychainImporter.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.11.13.
//
//

#import "NSDate+RFCFormats.h"
#import "NSString+TPWExtensions.h"
#import "TPWFileUtil.h"
#import "TPWMetadataPersistence.h"
#import "TPWPooledAsyncHttpClient.h"

#import "TPWWebDAVAgileKeychainImporter.h"
#import "TPWWebDAVPropfindResponseParser.h"

@interface TPWWebDAVAgileKeychainImporter ()
@property (nonatomic, strong) TPWPooledAsyncHttpClient *httpClient;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation TPWWebDAVAgileKeychainImporter

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password {
	if (self = [super init]) {
		self.username = username;
		self.password = password;
	}
	return self;
}

- (void)initializeHttpClient {
	@synchronized(self) {
		if (!self.httpClient) {
			self.httpClient = [[TPWPooledAsyncHttpClient alloc] init];
			self.httpClient.username = self.username;
			self.httpClient.password = self.password;
		}
	}
}

- (void)cancel {
	[self.httpClient cancelAllRequest];
	[super cancel];
}

- (void)cleanupAfterSuccessfulImport {
	self.httpClient = nil;
}

#pragma mark - TPWDataDefaultMetadataImporter, TPWContentsMetadataImporter

- (void)loadMetadataForDataDefaultDirectoryWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	[self initializeHttpClient];
	
	NSURL *url = [NSURL URLWithString:self.sourceDataDefaultPath];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"PROPFIND";
	[request addValue:@"1" forHTTPHeaderField:@"Depth"];
	
	// load:
	[self.httpClient makeRequest:request downloadToPath:nil onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		if (error) {
			callback(NO, error);
			return;
		}
		
		// parse:
		TPWWebDAVPropfindResponseParser *parser = [[TPWWebDAVPropfindResponseParser alloc] initWithXMLData:response.responseData encoding:response.responseEncoding];
		[parser parseResponses:^(NSArray *responses, NSError *error) {
			if (error) {
				callback(NO, error);
				return;
			}
			
			[self setRemoteRevisionDates:responses];
			callback(YES, nil);
		}];
	} onProgress:nil];
}

- (void)setRemoteRevisionDates:(NSArray*)propfindResponses {
	NSMutableDictionary *revisions = [NSMutableDictionary dictionaryWithCapacity:propfindResponses.count];
	NSURL *url = [NSURL URLWithString:self.sourceDataDefaultPath];
	NSString *workingDirectory = [url.path stringByAddingPercentEscapesUsingEncoding:kTPWHttpPercentEncodingCharset];
	NSString *standardizedWorkingDirectory = [workingDirectory stringByStandardizingPath];
	for (TPWWebDAVResponse *response in propfindResponses) {
		NSString *standardizedResponseHref = [response.href stringByStandardizingPath];
		BOOL isWorkingDirectory = [standardizedResponseHref isEqualToString:standardizedWorkingDirectory];
		if (!isWorkingDirectory) {
			NSString *filename = response.href.lastPathComponent;
			revisions[filename] = [response.lastModified rfc822String];
		}
	}
	self.remotePayloadRevisions = revisions;
}

- (void)loadMetadataForContentsFileWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	[self initializeHttpClient];
	
	NSString *contentsFilePath = [self.sourceDataDefaultPath URLStringByAppendingPathComponent:kTPWContentsFileName];
	NSURL *url = [NSURL URLWithString:contentsFilePath];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"HEAD";
	
	// load:
	[self.httpClient makeRequest:request downloadToPath:nil onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		if (error) {
			callback(NO, error);
			return;
		}
		
		// parse:
		self.keychainModificationDate = [NSDate dateFromRFC822:response.response.allHeaderFields[kTPWHttpLastModifiedHeaderFieldKey]];
		callback(YES, nil);
	} onProgress:nil];
}

#pragma mark - TPWFileImporter

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(destinationPath);
	NSParameterAssert(callback);
	[self initializeHttpClient];
	
	NSURL *url = [NSURL URLWithString:sourcePath];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"GET";
	
	// load:
	[self.httpClient makeRequest:request downloadToPath:destinationPath onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		BOOL success = error == nil && response.response.statusCode >= 200 && response.response.statusCode < 300;
		callback(success, error);
	} onProgress:nil];
}

#pragma mark - Accessors

- (NSString*)importerSource {
	return kTPWMetadataValueSourceWebDAV;
}

@end
