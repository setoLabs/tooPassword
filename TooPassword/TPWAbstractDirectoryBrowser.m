//
//  TPWAbstractDirectoryBrowser.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWAbstractDirectoryBrowser.h"
#import "TPWAbstractImporter.h"

@implementation TPWAbstractDirectoryBrowser

- (id)initWithWorkingDirectory:(NSString *)path {
	NSParameterAssert(path);
	
	if (self = [super init]) {
		self.path = path;
	}
	
	return self;
}

- (TPWAbstractDirectoryBrowser *)browserForWorkingDirectory:(NSString *)path {
	NSAssert(false, @"Overwrite this method.");
	return nil;
}

- (NSString *)relativeWorkingDirectoryForDisplay {
	return self.path;
}

- (BOOL)contentsOfDirectoryWillLoadImmediately {
	return NO;
}

- (void)contentsOfDirectory:(TPWContentsOfDirectoryCallback)callback {
	NSParameterAssert(callback);
	self.callback = callback;
}

- (void)cancel {
	NSAssert(false, @"Overwrite this method.");
}

- (BOOL)canImportFileAtPath:(NSString *)path {
	for (TPWAbstractImporter *importer in self.suitableImporters) {
		if ([importer canImportFileAtPath:path]) {
			return YES;
		}
	}
	return NO;
}

- (NSArray *)suitableImporters {
	NSAssert(false, @"Overwrite this method.");
	return nil;
}

- (TPWAbstractImporter *)importerForKeychainAtPath:(NSString *)path {
	for (TPWAbstractImporter *importer in self.suitableImporters) {
		if ([importer canImportFileAtPath:path]) {
			return importer;
		}
	}
	return nil;
}

- (NSString*)secondaryActionButtonTitle {
	// no secondary action by default
	return nil;
}

- (BOOL)performSecondaryActionAndContinueBrowsingIfWithoutError:(NSError **)error {
	// should never be called anyway when using default implementation
	return NO;
}

@end
