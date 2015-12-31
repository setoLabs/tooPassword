//
//  TPWDropboxAgileKeychainImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWDBRestClient.h"
#import "TPWMetadataPersistence.h"

#import "TPWDropboxAgileKeychainImporter.h"

@interface TPWDropboxAgileKeychainImporter ()
@property (nonatomic, strong) TPWDBRestClient *restClient;
@end

@implementation TPWDropboxAgileKeychainImporter

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

- (void)cleanupAfterSuccessfulImport {
	// do nothing
}

#pragma mark -
#pragma mark TPWDataDefaultMetadataImporter, TPWContentsMetadataImporter

- (void)loadMetadataForDataDefaultDirectoryWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	[self initializeRestClient];
	
	__weak TPWDropboxAgileKeychainImporter *weakSelf = self;
	[self.restClient loadMetadata:self.sourceDataDefaultPath onCompletion:^(DBMetadata *metadata, NSError *error) {
		if (error) {
			callback(NO, error);
			return;
		}
		
		// Traverse directory items
		NSMutableDictionary *revisions = [NSMutableDictionary dictionaryWithCapacity:metadata.contents.count];
		for (DBMetadata *fileMetadata in metadata.contents) {
			revisions[fileMetadata.filename] = fileMetadata.rev;
		}
		weakSelf.remotePayloadRevisions = revisions;
		
		callback(YES, nil);
	}];
}

- (void)loadMetadataForContentsFileWithCallback:(TPWLoadFileCallback)callback {
	NSParameterAssert(callback);
	[self initializeRestClient];
	
	__weak TPWDropboxAgileKeychainImporter *weakSelf = self;
	NSString *path = [self.sourceDataDefaultPath stringByAppendingPathComponent:kTPWContentsFileName];
	[self.restClient loadMetadata:path onCompletion:^(DBMetadata *metadata, NSError *error) {
		if (error) {
			callback(NO, error);
		} else {
			weakSelf.keychainModificationDate = metadata.lastModifiedDate;
			callback(YES, nil);
		}
	}];
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
	} onProgress:nil];
}

#pragma mark -
#pragma mark Accessors

- (NSString*)importerSource {
	return kTPWMetadataValueSourceDropbox;
}

@end
