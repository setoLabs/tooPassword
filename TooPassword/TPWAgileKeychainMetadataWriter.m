//
//  TPWAgileKeychainMetadataWriter.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 22.04.13.
//
//

#import "TPWAgileKeychainMetadataWriter.h"
#import "TPWMetadataPersistence.h"
#import "TPWFileUtil.h"

NSString *const kTPWAgileKeychainMetadataValueFormat = @"AgileKeychain";

@implementation TPWAgileKeychainMetadataWriter

- (void)writeMetadataToFile {
	NSDictionary *dict = @{
		kTPWMetadataKeyProductVersion: [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"],
		kTPWMetadataKeyImportDate: [NSDate date],
		kTPWMetadataKeyModificationDate: self.modificationDate,
		kTPWMetadataKeyPath: self.path,
		kTPWMetadataKeySource: self.source,
		kTPWMetadataKeyFormat: kTPWAgileKeychainMetadataValueFormat,
		kTPWMetadataKeyRevisionNumbers: self.revisionNumbers
	};
	NSString *metadataPath = [TPWFileUtil keychainInfoPath];
	[dict writeToFile:metadataPath atomically:YES];
}

@end
