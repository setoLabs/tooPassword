//
//  TPWUtilities.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/13/13.
//
//

#import "TPWFileUtil.h"
#import "TPWConstants.h"
#import "TPWMetadataReader.h"
#import "NSString+TPWExtensions.h"

@implementation TPWFileUtil

#pragma mark -
#pragma mark Paths

+ (NSString *)documentsPath {
	static NSString *documentsPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		documentsPath = [NSSearchPathForDirectoriesInDomains(kTPWSearchPathForLocationOfDocumentsDirectory, NSUserDomainMask, YES) firstObject];
	});
	return documentsPath;
}

+ (NSString *)documentsInboxPath {
	static NSString *documentsInboxPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		documentsInboxPath = [TPWFileUtil documentsPath];
		documentsInboxPath = [documentsInboxPath stringByAppendingPathComponent:kTPWInboxDirectory];
	});
	return documentsInboxPath;
}

+ (NSString *)privateDocumentsPath {
	static NSString *privateDocumentsPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		privateDocumentsPath = [NSSearchPathForDirectoriesInDomains(kTPWSearchPathForLocationOfPrivateDocumentsDirectory, NSUserDomainMask, YES) firstObject];
		privateDocumentsPath = [privateDocumentsPath stringByAppendingPathComponent:kTPWPrivateDocumentsDirectory];
	});
	return privateDocumentsPath;
}

+ (NSString *)keychainPath {
	static NSString *keychainPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keychainPath = [TPWFileUtil privateDocumentsPath];
		keychainPath = [keychainPath stringByAppendingPathComponent:kTPWPrivateKeychainDirectory];
	});
	return keychainPath;
}

+ (NSString *)keychainTmpPath {
	static NSString *keychainTmpPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keychainTmpPath = [TPWFileUtil privateDocumentsPath];
		keychainTmpPath = [keychainTmpPath stringByAppendingPathComponent:kTPWPrivateKeychainTempDirectory];
	});
	return keychainTmpPath;
}

+ (NSString *)keychainInfoPath {
	static NSString *keychainPath = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		keychainPath = [TPWFileUtil privateDocumentsPath];
		keychainPath = [keychainPath stringByAppendingPathComponent:kTPWPrivateKeychainInfoFileName];
	});
	return keychainPath;
}

+ (NSString *)keychainDataDefaultPath:(NSString *)path {
	NSString *result = [path URLStringByAppendingPathComponent:kTPWKeychainDataDirectory];
	return [result URLStringByAppendingPathComponent:kTPWKeychainDataDefaultDirectory];
}

#pragma mark -
#pragma mark Keychain Management

+ (void)eraseKeychain {
	NSString *path = [TPWFileUtil privateDocumentsPath];
	[[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
}

+ (BOOL)keychainIsValid {
	TPWMetadataReader *reader = [TPWMetadataReader reader];
	return (reader != nil);
}

@end
