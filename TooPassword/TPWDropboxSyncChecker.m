//
//  TPWDropboxSyncChecker.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.05.13.
//
//

#import "TPWConstants.h"
#import "TPWFileUtil.h"

#import "TPWDropboxSyncChecker.h"
#import "TPWMetadataPersistence.h"
#import "TPWReachability.h"
#import "TPWDBRestClient.h"
#import "TPWDropboxAgileKeychainImporter.h"

@interface TPWDropboxSyncChecker ()
@property (nonatomic, strong) TPWDBRestClient *restClient;
@end

@implementation TPWDropboxSyncChecker

- (id)init {
	if (self = [super init]) {
		self.restClient = [[TPWDBRestClient alloc] init];
	}
	return self;
}

- (void)checkSyncPossibility:(TPWSyncCheckCallback)callback {
	NSString *keychainDataDefaultPath = [TPWFileUtil keychainDataDefaultPath:self.reader.path];
	NSString *keychainContentsPath = [keychainDataDefaultPath stringByAppendingPathComponent:kTPWContentsFileName];
	
	if ([TPWReachability dropboxIsReachable] && [[DBSession sharedSession] isLinked]) {
		__weak TPWDropboxSyncChecker *weakSelf = self;
		[self.restClient loadMetadata:keychainContentsPath onCompletion:^(DBMetadata *metadata, NSError *error) {
			[weakSelf compareLocalMetadataWithRemote:metadata callback:callback];
		}];
	}
}

- (BOOL)canCheckSync:(NSString*)source {
	return [kTPWMetadataValueSourceDropbox isEqualToString:source];
}

- (NSArray*)suitableImporters {
	TPWDropboxAgileKeychainImporter *agileKeychainImporter = [[TPWDropboxAgileKeychainImporter alloc] init];
	return @[agileKeychainImporter];
}

- (void)compareLocalMetadataWithRemote:(DBMetadata*)metadata callback:(TPWSyncCheckCallback)callback {
	if (metadata == nil) {
		callback(NO, NO);
	} else {
		BOOL syncIsPossible = !metadata.isDeleted;
		BOOL hasChanges = syncIsPossible && ![metadata.lastModifiedDate isEqualToDate:self.reader.modificationDate];
		callback(syncIsPossible, hasChanges);
	}
}

@end
