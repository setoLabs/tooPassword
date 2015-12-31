//
//  TPWUtilities.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/13/13.
//
//

#import <Foundation/Foundation.h>

@interface TPWFileUtil : NSObject

// Paths.
+ (NSString *)documentsPath;
+ (NSString *)documentsInboxPath;
+ (NSString *)privateDocumentsPath;
+ (NSString *)keychainPath;
+ (NSString *)keychainTmpPath;
+ (NSString *)keychainInfoPath;
+ (NSString *)keychainDataDefaultPath:(NSString *)path;

// Keychain Management.
+ (void)eraseKeychain;
+ (BOOL)keychainIsValid;

@end
