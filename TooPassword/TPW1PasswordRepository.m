//
//  TPW1PasswordRepository.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 18.01.13.
//
//

#import "TPW1PasswordRepository.h"
#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPW1PasswordItem.h"
#import "TPWDecryptor.h"

NSString *const kTPW1PasswordRepositoryErrorDomain = @"TPW1PasswordRepositoryErrorDomain";

@interface TPW1PasswordRepository ()
@property (nonatomic, strong) NSArray *passwords;
@end

@implementation TPW1PasswordRepository

- (BOOL)loadPasswordsWithError:(NSError**)error {
	//prepare:
	NSDirectoryEnumerator *keychainDirEnum = [[NSFileManager defaultManager] enumeratorAtPath:[TPWFileUtil keychainPath]];
	NSMutableArray *array = [NSMutableArray array];
	NSMutableArray *unreadableFiles = [NSMutableArray array];
	
	//traverse:
	NSString *fileName;
	while (fileName = [keychainDirEnum nextObject]) {
		if ([kTPW1PasswordFileExtension isEqualToString:fileName.pathExtension]) {
			//read file:
			NSString *filePath = [[TPWFileUtil keychainPath] stringByAppendingPathComponent:fileName];
			NSData *data = [NSData dataWithContentsOfFile:filePath];
			TPW1PasswordItem *item = [TPW1PasswordItem itemWithJson:data];
			if (item) {
				[array addObject:item];
			} else {
				[unreadableFiles addObject:fileName];
			}
		}
	}
	
	//generate NSError, if there should be unreadable files
	if (unreadableFiles.count > 0) {
		NSString *errorMessage = NSLocalizedString(@"error.unreadable1PasswordFiles", @"error message, if parsing of .1password files failed");
		NSMutableString *completeErrorDescription = [NSMutableString stringWithString:errorMessage];
		for (NSString *unreadableFile in unreadableFiles) {
			[completeErrorDescription appendFormat:@"\n%@", unreadableFile];
		}
		if (error != NULL) {
			*error = [NSError errorWithDomain:kTPW1PasswordRepositoryErrorDomain
										 code:TPW1PasswordRepositoryErrorDuringParsing
									 userInfo:@{NSLocalizedDescriptionKey: completeErrorDescription}];
			return NO;
		}
	}
	
	//done
	self.passwords = array;
	
	return YES;
}

- (void)decryptPasswords {
	TPWDecryptor *decryptor = [TPWDecryptor sharedInstance];
	for (TPW1PasswordItem *password in self.passwords) {
		[password decryptByAcceptingDecryptor:decryptor];
	}
}

- (void)wipeData {
	self.passwords = nil;
}

#pragma mark - lifecylce

+ (TPW1PasswordRepository*)sharedInstance {
	static dispatch_once_t onceToken;
	static TPW1PasswordRepository *instance;
	dispatch_once(&onceToken, ^{
		instance = [[TPW1PasswordRepository alloc] init];
	});
	return instance;
}

@end
