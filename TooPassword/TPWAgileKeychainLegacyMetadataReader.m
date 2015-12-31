//
//  TPWAgileKeychainLegacyMetadataReader.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.04.13.
//
//

#import "TPWAgileKeychainLegacyMetadataReader.h"

NSString *const kTPWAgileKeychainLegacyKeyProductVersion = @"ProductVersion";
NSString *const kTPWAgileKeychainLegacyKeySource = @"KeychainSource";
NSString *const kTPWAgileKeychainLegacyKeyPath = @"KeychainPath";
NSString *const kTPWAgileKeychainLegacyKeyModificationDate = @"KeychainModifiedDate";
NSString *const kTPWAgileKeychainLegacyKeyImportDate = @"KeychainImportDate";
NSString *const kTPWAgileKeychainLegacyKeyRevisionNumbers = @"Keychain";

NSString *const kTPWAgileKeychainLegacyKeychainKeyFilename = @"filename";
NSString *const kTPWAgileKeychainLegacyKeychainKeyRevision = @"hash";

NSString *const kTPWAgileKeychainLegacyMaxVersion = @"741";

@implementation TPWAgileKeychainLegacyMetadataReader

- (void)readDictionary:(NSDictionary*)dict {
	self.importDate = dict[kTPWAgileKeychainLegacyKeyImportDate];
	self.modificationDate = dict[kTPWAgileKeychainLegacyKeyModificationDate];
	self.path = dict[kTPWAgileKeychainLegacyKeyPath];
	self.source = dict[kTPWAgileKeychainLegacyKeySource];
	NSArray *infoDicts = dict[kTPWAgileKeychainLegacyKeyRevisionNumbers];
	NSMutableDictionary *revisionNumbers = [NSMutableDictionary dictionaryWithCapacity:infoDicts.count];
	for (NSDictionary *infoDict in infoDicts) {
		NSString *key = infoDict[kTPWAgileKeychainLegacyKeychainKeyFilename];
		NSString *value = infoDict[kTPWAgileKeychainLegacyKeychainKeyRevision];
		revisionNumbers[key] = value;
	}
	self.revisionNumbers = revisionNumbers;
}

- (BOOL)canReadFormat:(NSString*)format version:(NSString*)version {
	return format == nil && version != nil && [version compare:kTPWAgileKeychainLegacyMaxVersion options:NSNumericSearch] != NSOrderedDescending;
}

@end
