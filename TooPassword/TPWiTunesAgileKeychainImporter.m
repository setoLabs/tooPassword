//
//  TPWiTunesAgileKeychainImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWMetadataPersistence.h"

#import "TPWiTunesAgileKeychainImporter.h"

@implementation TPWiTunesAgileKeychainImporter

- (void)cleanupAfterSuccessfulImport {
	[[NSFileManager defaultManager] removeItemAtPath:self.sourcePath error:NULL];
}

#pragma mark -
#pragma mark TPWDataDefaultMetadataImporter, TPWContentsMetadataImporter

- (void)loadMetadataForDataDefaultDirectoryWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	
	// Step 1: Load directory contents
	NSError *error = nil;
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sourceDataDefaultPath error:&error];
	if (error) {
		callback(NO, error);
		return;
	}
	
	// Step 2: Add items to payloadRevisions
	NSMutableDictionary *revisions = [NSMutableDictionary dictionaryWithCapacity:directoryContents.count];
	for (NSString *filename in directoryContents) {
		revisions[filename] = @""; //iTunes import: Moving files is faster than dealing with revision numbers :)=
	}
	self.remotePayloadRevisions = revisions;
	
	callback(YES, nil);
}

- (void)loadMetadataForContentsFileWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	
	// Step 1: Load directory attributes
	NSError *error = nil;
	NSString *path = [self.sourceDataDefaultPath stringByAppendingPathComponent:kTPWContentsFileName];
	NSDictionary *directoryAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
	if (error) {
		callback (NO, error);
		return;
	}
	
	// Step 2: Determine keychain modification date
	self.keychainModificationDate = directoryAttributes[NSFileModificationDate];
	
	callback(YES, nil);
}

#pragma mark -
#pragma mark TPWFileImporter

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(destinationPath);
	NSParameterAssert(callback);
	
	NSError *error = nil;
	BOOL success = [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destinationPath error:&error];
	callback(success, error);
}

#pragma mark -
#pragma mark Accessors

- (NSString*)importerSource {
	return kTPWMetadataValueSourceiTunes;
}

@end
