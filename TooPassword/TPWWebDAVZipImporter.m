//
//  TPWWebDAVZipImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 11/12/13.
//
//

#import "TPWPooledAsyncHttpClient.h"

#import "TPWWebDAVZipImporter.h"

@interface TPWWebDAVZipImporter ()
@property (nonatomic, strong) TPWPooledAsyncHttpClient *httpClient;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@end

@implementation TPWWebDAVZipImporter

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

#pragma mark -
#pragma mark TPWFileImporter

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
	} onProgress:^(CGFloat progress) {
		progressCallback(progress);
	}];
}

@end
