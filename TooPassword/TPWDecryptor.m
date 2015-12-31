//
//  TPWDecryptor.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 12.01.13.
//
//

#import "TPWDecryptor.h"
#import <CommonCrypto/CommonCrypto.h>
#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "NSData+Base64.h"
#import "NSData+MD5.h"

//PBKDF2
NSUInteger const kTPWPRFDefaultIterationCount = 1000; //default was 1000 until the iteration count was introduced in the json format
CCPseudoRandomAlgorithm const kTPWPRFAlgorithm = kCCPRFHmacAlgSHA1; //RFC 2898 default
NSUInteger const kTPWPRFKeySize = kCCKeySizeAES256;

//json parsing:
NSString *const kTPWJsonListKey = @"list";
NSString *const kTPWJsonSecurityLevelKey = @"level";
NSString *const kTPWJsonDataKey = @"data";
NSString *const kTPWJsonValidationKey = @"validation";
NSString *const kTPWJsonIterationsKey = @"iterations";

NSString *const kTPW1PasswordSaltedPrefix = @"Salted__";

#pragma mark -

@interface TPWDecryptor ()
@property (nonatomic, strong) NSString *pathOfCurrentlyUsedKeyFile;
@property (nonatomic, strong) NSData *checksumOfCurrentlyUsedKeyFile;
@property (nonatomic, strong) NSMutableDictionary *masterKeys;
@end

#pragma mark -

@implementation TPWDecryptor

- (BOOL)decryptMasterKeysWithPassword:(NSString *)masterPassword {
	//read and parse data:
	NSDictionary *parsedKeychain = [self loadEncryptedMasterKeysFromFilesystem];
	if (parsedKeychain == nil) return NO;
	NSArray *keyDicts = parsedKeychain[kTPWJsonListKey];
	if (keyDicts == nil) return NO;
	
	//prepare masterkeys dictionary
	self.masterKeys = [NSMutableDictionary dictionaryWithCapacity:keyDicts.count];
	
	//parse all available masterkeys
	for (NSDictionary *keyDict in keyDicts) {
		BOOL success = [self decryptMasterKey:keyDict withPassword:masterPassword];
		if (!success) {
			[self wipeMasterKeys];
			return NO;
		}
	}
	
	//successful, if not already returned in loop
	return YES;
}

- (BOOL)decryptMasterKey:(NSDictionary*)keyDict withPassword:(NSString*)masterPassword {
	NSData *saltedCiphertext = [NSData dataWithBase64Representation:keyDict[kTPWJsonDataKey]];
	if (saltedCiphertext == nil) return NO;
	if (![self isSalted:saltedCiphertext]) return NO;
	
	//fetch security level
	NSString *securityLevel = keyDict[kTPWJsonSecurityLevelKey];
	
	//derive key to decrypt the master key
	NSUInteger iterationCount = (keyDict[kTPWJsonIterationsKey]) ? [keyDict[kTPWJsonIterationsKey] unsignedIntegerValue] : kTPWPRFDefaultIterationCount;
	NSData *password = [masterPassword dataUsingEncoding:NSUTF8StringEncoding];
	NSData *salt = [saltedCiphertext subdataWithRange:NSMakeRange(8, 8)];
	NSData *derivedKey = [self deriveKeyUsingPbkdf2WithPassword:password salt:salt iterationCount:iterationCount];
	if (derivedKey == nil) return NO;
	
	//decrypt raw masterkey
	NSData *ciphertext = [saltedCiphertext subdataWithRange:NSMakeRange(16, saltedCiphertext.length - 16)];
	NSData *decryptionKey = [derivedKey subdataWithRange:NSMakeRange(0, 16)];
	NSData *decryptionIv = [derivedKey subdataWithRange:NSMakeRange(16, 16)];
	NSData *masterKey = [self decryptData:ciphertext withKey:decryptionKey initializationVector:decryptionIv];
	if (masterKey == nil) return NO;
	
	//verify masterkey
	NSData *saltedValidation = [NSData dataWithBase64Representation:keyDict[kTPWJsonValidationKey]];
	NSData *decryptedValidation = [self decryptData:saltedValidation withMasterKey:masterKey];
	BOOL correctMasterKey = [masterKey isEqualToData:decryptedValidation];
	
	//store masterkey
	if (correctMasterKey) {
		self.masterKeys[securityLevel] = masterKey;
		DLog(@"successfuly decrypted masterkey with security level %@", securityLevel);
		return YES;
	} else {
		DLog(@"could not decrypt masterkey with security level %@", securityLevel);
		return NO;
	}
}

- (void)wipeMasterKeys {
	self.pathOfCurrentlyUsedKeyFile = nil;
	self.checksumOfCurrentlyUsedKeyFile = nil;
	self.masterKeys = nil;
}

/**
 PBKDF2
 */
- (NSData*)deriveKeyUsingPbkdf2WithPassword:(NSData*)password salt:(NSData*)salt iterationCount:(NSUInteger)iterations {
	uint8_t key[kTPWPRFKeySize] = {0};
	int result = CCKeyDerivationPBKDF(kCCPBKDF2,
									  [password bytes], [password length], //password
									  [salt bytes], [salt length], //salt
									  kTPWPRFAlgorithm, (uint)iterations, //PRF
									  key, kTPWPRFKeySize); //output
	if (result == kCCSuccess) {
		return [NSData dataWithBytes:key length:kTPWPRFKeySize];
	} else {
		NSAssert(result != kCCParamError, @"invalid hard-coded parameter in PBKDF. must not happen.");
		return nil;
	}
}

/**
 Schneier KDF
 @see http://www.di-mgt.com.au/cryptoKDFs.html#pbkdf-s
 */
- (NSData*)schneierMd5BasedKeyDerivationFunctionWithSeed:(NSData*)seed salt:(NSData*)salt iterations:(NSUInteger)iterations {
	//prepare salted data:
	NSMutableData *salted = [NSMutableData dataWithData:seed];
	[salted appendData:salt];
	
	//first iteration:
	NSData *hashed = [salted md5];
	NSMutableData *result = [NSMutableData dataWithData:hashed];
	
	//other iterations:
	for (int i=1; i<iterations; i++) {
		NSMutableData *input = [NSMutableData dataWithData:hashed];
		[input appendData:salted];
		hashed = [input md5];
		[result appendData:hashed];
	}
	
	return result;
}

#pragma mark - analysis of ciphertext

- (BOOL)isSalted:(NSData*)encrypted {
	NSParameterAssert(encrypted.length > 8);
	NSData *potentialPrefix = [encrypted subdataWithRange:NSMakeRange(0, 8)];
	NSString *potentialPrefixStr = [[NSString alloc] initWithData:potentialPrefix encoding:NSASCIIStringEncoding];
	return [kTPW1PasswordSaltedPrefix isEqualToString:potentialPrefixStr];
}

#pragma mark - decryption

- (NSData*)decryptData:(NSData*)encrypted withSecurityLevel:(NSString*)securityLevel {
	NSParameterAssert(encrypted);
	NSParameterAssert(securityLevel);
	NSData *masterKey = self.masterKeys[securityLevel];
	if (masterKey == nil) {
		return nil;
	} else {
		return [self decryptData:encrypted withMasterKey:masterKey];
	}
}

- (NSData*)decryptData:(NSData*)encrypted withMasterKey:(NSData*)masterKey {
	NSParameterAssert(encrypted);
	NSParameterAssert(masterKey);
	NSData *key;
	NSData *iv;
	if ([self isSalted:encrypted]) {
		NSData *salt = [encrypted subdataWithRange:NSMakeRange(8, 8)];
		encrypted = [encrypted subdataWithRange:NSMakeRange(16, encrypted.length - 16)];
		NSData *derivedKey = [self schneierMd5BasedKeyDerivationFunctionWithSeed:masterKey salt:salt iterations:2];
		key = [derivedKey subdataWithRange:NSMakeRange(0, 16)];
		iv = [derivedKey subdataWithRange:NSMakeRange(16, 16)];
	} else {
		key = [masterKey md5];
		iv = nil;
	}
	return [self decryptData:encrypted withKey:key initializationVector:iv];
}

- (NSData*)decryptData:(NSData*)ciphertext withKey:(NSData*)key initializationVector:(NSData*)initializationVector {
	NSParameterAssert(ciphertext);
	NSParameterAssert(key);
	NSParameterAssert(!initializationVector || initializationVector.length == kCCBlockSizeAES128);
	size_t outputBufferSize = [ciphertext length] + kCCBlockSizeAES128;
	char outputBuffer[outputBufferSize];
	size_t actualOutputSize;
	CCCryptorStatus result = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
									 [key bytes], [key length], [initializationVector bytes],
									 [ciphertext bytes], [ciphertext length],
									 &outputBuffer, outputBufferSize, &actualOutputSize);
	if (result == kCCSuccess) {
		return [NSData dataWithBytes:outputBuffer length:actualOutputSize];
	} else {
		DLog(@"decryption failed. ciphertext: %@", ciphertext);
		return nil;
	}
}

#pragma mark - check if masterkey exists

- (BOOL)isUnlocked {
	return self.masterKeys.count > 0;
}

#pragma mark - filesystem stuff

- (NSDictionary*)loadEncryptedMasterKeysFromFilesystem {
	NSString *keychainPath = [TPWFileUtil keychainPath];
	NSString *jsonKeyFilePath = [keychainPath stringByAppendingPathComponent:kTPWEncryptionKeysFileName];
	NSString *plistKeyFilePath = [keychainPath stringByAppendingPathComponent:kTPW1PasswordKeysFileName];
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:jsonKeyFilePath]) {
		return [self loadEncryptedMasterKeysFromJsonFile:jsonKeyFilePath];
	} else if ([[NSFileManager defaultManager] fileExistsAtPath:plistKeyFilePath]) {
		return [self loadEncryptedMasterKeysFromPlistFile:plistKeyFilePath];
	} else {
		NSAssert(false, @"neither %@, nor %@ found.", jsonKeyFilePath, plistKeyFilePath);
		return nil;
	}
}

- (NSDictionary*)loadEncryptedMasterKeysFromJsonFile:(NSString*)path {
	//store checksum for future comparison:
	[self saveChecksumOfFileAtPath:path];
	
	//read json file:
	NSData *jsonData = [NSData dataWithContentsOfFile:path];
	NSAssert(jsonData, @"could not read file: %@", path);
	
	//parse json:
	NSError *error;
	NSDictionary *result = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	NSAssert(!error, @"corrupt json data: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]);
	
	return result;
}

- (NSDictionary*)loadEncryptedMasterKeysFromPlistFile:(NSString*)path {
	//store checksum for future comparison:
	[self saveChecksumOfFileAtPath:path];
	
	//parse plist:
	NSDictionary *result = [NSDictionary dictionaryWithContentsOfFile:path];
	NSAssert(result, @"could not parse plist file: %@", path);
	
	return result;
}

- (void)saveChecksumOfFileAtPath:(NSString*)path {
	NSData *filecontents = [NSData dataWithContentsOfFile:path];
	self.pathOfCurrentlyUsedKeyFile = path;
	self.checksumOfCurrentlyUsedKeyFile = filecontents.md5;
}

- (BOOL)hasEncryptionKeysFileChanged {
	NSData *filecontents = [NSData dataWithContentsOfFile:self.pathOfCurrentlyUsedKeyFile];
	return ![self.checksumOfCurrentlyUsedKeyFile isEqualToData:filecontents.md5];
}

#pragma mark - lifecycle

+ (TPWDecryptor*)sharedInstance {
	static dispatch_once_t onceToken;
	static TPWDecryptor *instance;
	dispatch_once(&onceToken, ^{
		instance = [[TPWDecryptor alloc] init];
	});
	return instance;
}

@end
