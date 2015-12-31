//
//  TPWDBRestClient.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/24/13.
//
//

#import "TPWDBRestClient.h"
#import "NSString+TPWDropboxQuirks.h"

@interface TPWDBRestClient () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, strong) NSMutableDictionary *fileLoadCompletionCallbacks;
@property (nonatomic, strong) NSMutableDictionary *fileLoadProgressCallbacks;
@property (nonatomic, strong) NSMutableDictionary *metadataLoadCompletionCallbacks;
@end

@implementation TPWDBRestClient

- (id)init {
	if (self = [super init]) {
		self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		self.restClient.delegate = self;
		self.fileLoadCompletionCallbacks = [NSMutableDictionary dictionary];
		self.fileLoadProgressCallbacks = [NSMutableDictionary dictionary];
		self.metadataLoadCompletionCallbacks = [NSMutableDictionary dictionary];
	}
	return self;
}

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWDBRestClientLoadFileCallback)callback onProgress:(TPWDBRestClientLoadFileProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(destinationPath);
	NSParameterAssert(callback);
	NSString *callbackKey = [destinationPath normalizedDropboxPathForUseAsDictKey];
	
	self.fileLoadCompletionCallbacks[callbackKey] = [callback copy];
	if (progressCallback) {
		self.fileLoadProgressCallbacks[callbackKey] = [progressCallback copy];
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.restClient loadFile:sourcePath intoPath:destinationPath];
	});
}

- (void)loadMetadata:(NSString *)sourcePath onCompletion:(TPWDBRestClientMetadataCallback)callback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(callback);
	NSString *callbackKey = [sourcePath normalizedDropboxPathForUseAsDictKey];
	
	self.metadataLoadCompletionCallbacks[callbackKey] = [callback copy];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.restClient loadMetadata:sourcePath];
	});
}

- (void)cancelAll {
	[self.restClient cancelAllRequests];
}

- (void)cancelLoadOfFile:(NSString*)sourcePath {
	[self.restClient cancelFileLoad:sourcePath];
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath {
	NSString *callbackKey = [destPath normalizedDropboxPathForUseAsDictKey];
	
	TPWDBRestClientLoadFileCallback completion = self.fileLoadCompletionCallbacks[callbackKey];
	if (completion) {
		completion(YES, nil);
	}
	[self.fileLoadCompletionCallbacks removeObjectForKey:destPath];
	[self.fileLoadProgressCallbacks removeObjectForKey:destPath];
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
	NSString *destPath = error.userInfo[@"destinationPath"];
	NSString *callbackKey = [destPath normalizedDropboxPathForUseAsDictKey];
	
	TPWDBRestClientLoadFileCallback completion = self.fileLoadCompletionCallbacks[callbackKey];
	if (completion) {
		completion(NO, error);
	}
	[self.fileLoadCompletionCallbacks removeObjectForKey:destPath];
	[self.fileLoadProgressCallbacks removeObjectForKey:destPath];
}

- (void)restClient:(DBRestClient *)client loadProgress:(CGFloat)progress forFile:(NSString *)destPath {
	NSString *callbackKey = [destPath normalizedDropboxPathForUseAsDictKey];
	
	TPWDBRestClientLoadFileProgressCallback progressCallback = self.fileLoadProgressCallbacks[callbackKey];
	if (progressCallback) {
		progressCallback(progress);
	}
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
	NSString *callbackKey = [metadata.path normalizedDropboxPathForUseAsDictKey];
	
	TPWDBRestClientMetadataCallback completion = self.metadataLoadCompletionCallbacks[callbackKey];
	if (completion) {
		completion(metadata, nil);
	}
	[self.metadataLoadCompletionCallbacks removeObjectForKey:metadata];
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
	NSString *srcPath = error.userInfo[@"path"];
	NSString *callbackKey = [srcPath normalizedDropboxPathForUseAsDictKey];
	
	TPWDBRestClientMetadataCallback completion = self.metadataLoadCompletionCallbacks[callbackKey];
	if (completion) {
		completion(nil, error);
	}
	[self.metadataLoadCompletionCallbacks removeObjectForKey:srcPath];
}

@end
