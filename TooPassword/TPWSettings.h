//
//  TPWSettings.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/26/13.
//
//

#import <Foundation/Foundation.h>

extern BOOL const kTPWSettingsSimpleSearchDefaultValue;

extern NSTimeInterval const kTPWSettingsAutoLockTimeIntervalInstant;
extern NSTimeInterval const kTPWSettingsAutoLockTimeInterval60;
extern NSTimeInterval const kTPWSettingsAutoLockTimeInterval120;
extern NSTimeInterval const kTPWSettingsAutoLockTimeInterval300;
extern NSTimeInterval const kTPWSettingsAutoLockTimeInterval600;
extern NSTimeInterval const kTPWSettingsAutoLockDefaultValue;

extern NSTimeInterval const kTPWSettingsClearClipboardTimeInterval30;
extern NSTimeInterval const kTPWSettingsClearClipboardTimeInterval60;
extern NSTimeInterval const kTPWSettingsClearClipboardTimeInterval120;
extern NSTimeInterval const kTPWSettingsClearClipboardTimeInterval300;
extern NSTimeInterval const kTPWSettingsClearClipboardTimeIntervalNever;
extern NSTimeInterval const kTPWSettingsClearClipboardDefaultValue;

extern BOOL const kTPWSettingsConcealPasswordsDefaultValue;

@interface TPWSettings : NSObject

+ (TPWSettings *)sharedInstance;
- (void)loadFromUserDefaults;
- (void)saveToUserDefaults;
- (void)resetUserDefaults;

//convenience methods
+ (void)setSimpleSearch:(BOOL)simpleSearch;
+ (BOOL)simpleSearch;
+ (void)setAutoLockTimeInterval:(NSTimeInterval)autoLockTimeInterval;
+ (NSTimeInterval)autoLockTimeInterval;
+ (void)setClearClipboardTimeInterval:(NSTimeInterval)clearClipboardTimeInterval;
+ (NSTimeInterval)clearClipboardTimeInterval;
+ (void)setConcealPasswords:(BOOL)concealPasswords;
+ (BOOL)concealPasswords;
+ (void)setWebDAVUrl:(NSString *)webDAVUrl;
+ (NSString *)webDAVUrl;
+ (void)setWebDAVUser:(NSString *)webDAVUser;
+ (NSString *)webDAVUser;
+ (void)setWebDAVPass:(NSString *)webDAVPass;
+ (NSString *)webDAVPass;
+ (void)setWebDAVShouldSavePass:(BOOL)webDAVShouldSavePass;
+ (BOOL)webDAVShouldSavePass;
+ (void)setWebDAVShouldTrustAllSSL:(BOOL)webDAVShouldTrustAllSSL;
+ (BOOL)webDAVShouldTrustAllSSL;

@end
