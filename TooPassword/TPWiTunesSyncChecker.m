//
//  TPWiTunesSyncChecker.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.05.13.
//
//

#import "TPWConstants.h"
#import "TPWFileUtil.h"

#import "TPWiTunesSyncChecker.h"
#import "TPWMetadataPersistence.h"
#import "TPWiTunesAgileKeychainImporter.h"

@implementation TPWiTunesSyncChecker

- (void)checkSyncPossibility:(TPWSyncCheckCallback)callback {
	NSString *keychainDataDefaultPath = [TPWFileUtil keychainDataDefaultPath:self.reader.path];
	NSString *keychainContentsPath = [keychainDataDefaultPath stringByAppendingPathComponent:kTPWContentsFileName];
	
	BOOL syncIsPossible = [[NSFileManager defaultManager] fileExistsAtPath:keychainContentsPath isDirectory:NULL];
	BOOL hasChanges = NO;
	
	if (syncIsPossible) {
		NSDictionary *pathAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:keychainContentsPath error:nil];
		hasChanges = ![pathAttributes[NSFileModificationDate] isEqualToDate:self.reader.modificationDate];
	}
	
	callback(syncIsPossible, hasChanges);
}

- (BOOL)canCheckSync:(NSString*)source {
	return [kTPWMetadataValueSourceiTunes isEqualToString:source];
}

- (NSArray *)suitableImporters {
	TPWiTunesAgileKeychainImporter *agileKeychainImporter = [[TPWiTunesAgileKeychainImporter alloc] init];
	return @[agileKeychainImporter];
}

@end
