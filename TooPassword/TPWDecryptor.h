//
//  TPWDecryptor.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 12.01.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWDecryptor : NSObject

- (BOOL)decryptMasterKeysWithPassword:(NSString *)masterPassword;
- (void)wipeMasterKeys;
- (NSData*)decryptData:(NSData*)encrypted withSecurityLevel:(NSString*)securityLevel;

- (BOOL)isUnlocked; //checks, if master keys exist
- (BOOL)hasEncryptionKeysFileChanged;

+ (TPWDecryptor*)sharedInstance;

@end
