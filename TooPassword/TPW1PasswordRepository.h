//
//  TPW1PasswordRepository.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 18.01.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kTPW1PasswordRepositoryErrorDomain;

typedef enum {
	TPW1PasswordRepositoryErrorDuringParsing
} TPW1PasswordRepositoryError;

@interface TPW1PasswordRepository : NSObject
@property (nonatomic, readonly) NSArray *passwords;

- (BOOL)loadPasswordsWithError:(NSError**)error;
- (void)decryptPasswords;
- (void)wipeData;

+ (TPW1PasswordRepository*)sharedInstance;

@end
