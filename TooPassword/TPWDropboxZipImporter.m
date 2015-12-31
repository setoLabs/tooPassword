//
//  TPWDropboxZipImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 7/5/13.
//
//

#import "TPWDBRestClient.h"

#import "TPWDropboxZipImporter.h"

@interface TPWDropboxZipImporter ()
@property (nonatomic, strong) TPWDBRestClient *restClient;
@end

@implementation TPWDropboxZipImporter

- (void)initializeRestClient {
	@synchronized(self) {
		if (!self.restClient) {
			self.restClient = [[TPWDBRestClient alloc] init];
		}
	}
}

- (void)cancel {
	[self.restClient cancelAll];
	[super cancel];
}

#pragma mark -
#pragma mark TPWFileImporter

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(destinationPath);
	NSParameterAssert(callback);
	
	[self initializeRestClient];
	
	[self.restClient loadFile:sourcePath intoPath:destinationPath onCompletion:^(BOOL success, NSError *error) {
		callback(success, error);
	} onProgress:^(CGFloat progress) {
		progressCallback(progress);
	}];
}

@end
