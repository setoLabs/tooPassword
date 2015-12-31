//
//  TPWWebDAVDirectoryBrowser.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.11.13.
//
//

#import "TPWWebDAVDirectoryBrowser.h"
#import "TPWSettings.h"
#import "NSString+TPWExtensions.h"

#import "TPWPooledAsyncHttpClient.h"
#import "TPWWebDAVPropfindResponseParser.h"

#import "TPWWebDAVAgileKeychainImporter.h"
#import "TPWWebDAVZipImporter.h"

NSString *const kTPWWebDAVDirectoryBrowserErrorDomain = @"TPWWebDAVDirectoryBrowserErrorDomain";

@interface TPWWebDAVDirectoryBrowser () <NSXMLParserDelegate>
@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) TPWPooledAsyncHttpClient *httpClient;
@property (nonatomic, strong) TPWWebDAVPropfindResponseParser *parser;
@property (nonatomic, assign) BOOL loadInProgress;
@end

@implementation TPWWebDAVDirectoryBrowser

- (id)initWithWorkingDirectory:(NSString *)path basePath:(NSString*)basePath username:(NSString*)username password:(NSString*)password {
	if (self = [super initWithWorkingDirectory:path]) {
		self.basePath = basePath;
		self.url = [NSURL URLWithString:self.path];
		self.username = username;
		self.password = password;
		self.httpClient = [[TPWPooledAsyncHttpClient alloc] init];
		self.httpClient.username = username;
		self.httpClient.password = password;
	}
	return self;
}

- (id)initWithWorkingDirectory:(NSString *)path username:(NSString*)username password:(NSString*)password {
	return [self initWithWorkingDirectory:path basePath:path username:username password:password];
}

- (TPWAbstractDirectoryBrowser *)browserForWorkingDirectory:(NSString *)path {
	return [[TPWWebDAVDirectoryBrowser alloc] initWithWorkingDirectory:path basePath:self.basePath username:self.username password:self.password];
}

- (NSString *)relativeWorkingDirectoryForDisplay {
	NSString *relativePath = [self.path substringFromIndex:self.basePath.length];
	if (![relativePath hasPrefix:kTPWStringExtensionsPathSeperator]) {
		relativePath = [kTPWStringExtensionsPathSeperator stringByAppendingString:relativePath];
	}
	return [relativePath stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (void)contentsOfDirectory:(TPWContentsOfDirectoryCallback)callback {
	[super contentsOfDirectory:callback];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"PROPFIND";
	[request addValue:@"1" forHTTPHeaderField:@"Depth"];
	
	[self.httpClient makeRequest:request downloadToPath:nil onRedirect:^(NSNumber *tag, NSURL *newURL) {
		self.url = newURL;
		self.path = [newURL absoluteString];
		self.basePath = self.path; // reset base path on redirect
	} onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		if (!error) {
			[self parseResponse:response.responseData encoding:response.responseEncoding];
		} else {
			self.callback(nil, error);
		}
	} onProgress:nil];
}

- (void)parseResponse:(NSData*)xmlData encoding:(NSStringEncoding)encoding {
	self.parser = [[TPWWebDAVPropfindResponseParser alloc] initWithXMLData:xmlData encoding:encoding];
	[self.parser parseResponses:^(NSArray *responses, NSError *error) {
		if (!error) {
			self.callback([self filteredDirectoryItemsFromResponses:responses encoding:encoding], nil);
		} else {
			self.callback(nil, error);
		}
	}];
}

- (NSDictionary*)filteredDirectoryItemsFromResponses:(NSArray*)responses encoding:(NSStringEncoding)encoding {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:responses.count];
	NSString *normalizedWorkingDirectory = [self.path hasSuffix:kTPWStringExtensionsPathSeperator] ? self.path : [self.path stringByAppendingString:kTPWStringExtensionsPathSeperator];
	NSUInteger workingDirectoryDepth = [[normalizedWorkingDirectory pathComponents] count];
	
	for (TPWWebDAVResponse *response in responses) {
		NSURL *resourceUrl = [NSURL URLWithString:response.href relativeToURL:self.url];
		NSString *absolutePath = [resourceUrl absoluteString];
		NSUInteger absolutePathDepth = [[absolutePath pathComponents] count];
		NSString *filename = [[absolutePath lastPathComponent] stringByReplacingPercentEscapesUsingEncoding:encoding];
		BOOL isHidden = [filename hasPrefix:@"."];
		BOOL hasSameParentDirectory = [absolutePath hasPrefix:normalizedWorkingDirectory];
		BOOL isDirectChild = (absolutePathDepth == workingDirectoryDepth + (response.isCollection ? 1 : 0));
		BOOL isVisible = hasSameParentDirectory && isDirectChild && !isHidden;
		if (isVisible && (response.isCollection || [self canImportFileAtPath:absolutePath])) {
			result[absolutePath] = filename;
		}
	}

	return result;
}

- (void)cancel {
	[self.httpClient cancelAllRequest];
	[self.parser cancelParsing];
	
	if (self.loadInProgress) {
		self.loadInProgress = NO;
		
		// callback
		NSError *error = [[NSError alloc] initWithDomain:kTPWWebDAVDirectoryBrowserErrorDomain code:TPWWebDAVDirectoryBrowserErrorInterrupted userInfo:nil];
		self.callback(nil, error);
	}
}

- (NSArray *)suitableImporters {
	TPWWebDAVAgileKeychainImporter *agileKeychainImporter = [[TPWWebDAVAgileKeychainImporter alloc] initWithUsername:self.username password:self.password];
	TPWWebDAVZipImporter *zipImporter = [[TPWWebDAVZipImporter alloc] initWithUsername:self.username password:self.password];
	return @[agileKeychainImporter, zipImporter];
}

@end
