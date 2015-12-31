//
//  TPW1PasswordFieldKeyUtil.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kTPW1PasswordFieldLocalizationTable;

@interface TPW1PasswordFieldKeyUtil : NSObject

- (BOOL)shouldObfuscateValueForKey:(NSString*)key;
- (NSMutableDictionary*)shortenedTidyFieldDictionaryFromRawDictionary:(NSDictionary*)input;
- (NSMutableDictionary*)tidyFieldDictionaryFromRawDictionary:(NSDictionary*)input;
+ (TPW1PasswordFieldKeyUtil*)sharedInstance;

@end
