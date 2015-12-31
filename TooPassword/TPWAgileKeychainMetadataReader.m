//
//  TPWAgileKeychainMetadataReader.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.04.13.
//
//

#import "TPWAgileKeychainMetadataReader.h"

NSString *const kTPWAgileKeychainMinVersion = @"768";

@implementation TPWAgileKeychainMetadataReader

- (void)readDictionary:(NSDictionary*)dict {
	self.importDate = dict[kTPWMetadataKeyImportDate];
	self.modificationDate = dict[kTPWMetadataKeyModificationDate];
	self.path = dict[kTPWMetadataKeyPath];
	self.source = dict[kTPWMetadataKeySource];
	self.revisionNumbers = dict[kTPWMetadataKeyRevisionNumbers];
}

- (BOOL)canReadFormat:(NSString*)format version:(NSString*)version {
	return [format isEqualToString:kTPWMetadataValueFormat] && [version compare:kTPWAgileKeychainMinVersion options:NSNumericSearch] == NSOrderedDescending;
}

@end
