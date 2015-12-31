//
//  TPWMetadataReader.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.04.13.
//
//

#import "TPWFileUtil.h"

#import "TPWMetadataReader.h"
#import "TPWAgileKeychainMetadataReader.h"
#import "TPWAgileKeychainLegacyMetadataReader.h"

@implementation TPWMetadataReader

- (void)readDictionary:(NSDictionary*)dict {
	NSAssert(false, @"overwrite this method");
}

- (BOOL)canReadFormat:(NSString*)format version:(NSString*)version {
	NSAssert(false, @"overwrite this method");
	return NO;
}

+ (TPWMetadataReader*)reader {
	NSString *metadataPath = [TPWFileUtil keychainInfoPath];
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:metadataPath];
	NSString *format = dict[kTPWMetadataKeyFormat];
	NSString *productVersion = dict[kTPWMetadataKeyProductVersion];
	TPWMetadataReader *reader = [TPWMetadataReader readerAbleToReadFormat:format version:productVersion];
	[reader readDictionary:dict];
	return reader;
}

+ (TPWMetadataReader*)readerAbleToReadFormat:(NSString*)format version:(NSString*)version {
	for (TPWMetadataReader *reader in [TPWMetadataReader readers]) {
		if ([reader canReadFormat:format version:version]) {
			return reader;
		}
	}
	return nil;
}

+ (NSArray*)readers {
	static NSArray *readers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		TPWMetadataReader *agileKeychainLegacyMetadataReader = [[TPWAgileKeychainLegacyMetadataReader alloc] init];
		TPWMetadataReader *agileKeychainMetadataReader = [[TPWAgileKeychainMetadataReader alloc] init];
		readers = @[agileKeychainLegacyMetadataReader, agileKeychainMetadataReader];
	});
	return readers;
}

@end
