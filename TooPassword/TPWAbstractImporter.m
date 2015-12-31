//
//  TPWAbstractImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWFileUtil.h"

#import "TPWAbstractImporter.h"

@implementation TPWAbstractImporter

- (id)init {
	if (self = [super init]) {
		self.importerQueue = dispatch_queue_create("de.tobiha.TooPassword.queue.importer", DISPATCH_QUEUE_SERIAL);
	}
	return self;
}

- (void)dealloc {
	dispatch_release(self.importerQueue), self.importerQueue = NULL;
}

- (void)importKeychainAtPath:(NSString *)sourcePath onCompletion:(TPWImportCallback)callback onProgress:(TPWImportProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(callback);
	NSParameterAssert(progressCallback);
	self.sourcePath = sourcePath;
	self.callback = callback;
	self.progressCallback = progressCallback;
}

- (void)cancel {
	NSAssert(false, @"Overwrite this method.");
}

#pragma mark -
#pragma mark Callbacks

- (void)callbackWithSuccess {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.callback(YES, nil);
	});
}

- (void)callbackWithError:(NSError *)error {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.callback(NO, error);
	});
}

- (void)callbackWithProgress:(CGFloat)progress {
	dispatch_async(dispatch_get_main_queue(), ^{
		self.progressCallback(progress);
	});
}

#pragma mark -
#pragma mark TPWImportableFileChecking

- (BOOL)canImportFileAtPath:(NSString *)path {
	NSAssert(false, @"Overwrite this method.");
	return NO;
}

@end
