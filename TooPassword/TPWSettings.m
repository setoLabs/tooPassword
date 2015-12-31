//
//  TPWSettings.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/26/13.
//
//

#import "TPWSettings.h"
#import "FXKeychain.h"

BOOL const kTPWSettingsSimpleSearchDefaultValue = YES;

NSTimeInterval const kTPWSettingsAutoLockTimeIntervalInstant = 0.0;
NSTimeInterval const kTPWSettingsAutoLockTimeInterval60 = 60.0;
NSTimeInterval const kTPWSettingsAutoLockTimeInterval120 = 120.0;
NSTimeInterval const kTPWSettingsAutoLockTimeInterval300 = 300.0;
NSTimeInterval const kTPWSettingsAutoLockTimeInterval600 = 600.0;
NSTimeInterval const kTPWSettingsAutoLockDefaultValue = kTPWSettingsAutoLockTimeIntervalInstant;

NSTimeInterval const kTPWSettingsClearClipboardTimeInterval30 = 30.0;
NSTimeInterval const kTPWSettingsClearClipboardTimeInterval60 = 60.0;
NSTimeInterval const kTPWSettingsClearClipboardTimeInterval120 = 120.0;
NSTimeInterval const kTPWSettingsClearClipboardTimeInterval300 = 300.0;
NSTimeInterval const kTPWSettingsClearClipboardTimeIntervalNever = 0.0;
NSTimeInterval const kTPWSettingsClearClipboardDefaultValue = kTPWSettingsClearClipboardTimeInterval120;

BOOL const kTPWSettingsConcealPasswordsDefaultValue = YES;

NSString *const kTPWSettingsSimpleSearchKey = @"simpleSearch";
NSString *const kTPWSettingsAutoLockTimeIntervalKey = @"autoLockTimeInterval";
NSString *const kTPWSettingsClearClipboardTimeIntervalKey = @"clearClipboardTimeInterval";
NSString *const kTPWSettingsConcealPasswordsKey = @"concealPasswords";
NSString *const kTPWSettingsWebDAVUrlKey = @"webDAVUrl";
NSString *const kTPWSettingsWebDAVUserKey = @"webDAVUser";
NSString *const kTPWSettingsWebDAVPassKey = @"webDAVPass";
NSString *const kTPWSettingsWebDAVShouldSavePassKey = @"webDAVShouldSavePass";
NSString *const kTPWSettingsWebDAVShouldTrustAllSSLKey = @"webDAVShouldTrustAllSSL";

@interface TPWSettings ()
@property (nonatomic, assign) BOOL simpleSearch;
@property (nonatomic, assign) NSTimeInterval autoLockTimeInterval;
@property (nonatomic, assign) NSTimeInterval clearClipboardTimeInterval;
@property (nonatomic, assign) BOOL concealPasswords;
@property (nonatomic, strong) NSString *webDAVUrl;
@property (nonatomic, strong) NSString *webDAVUser;
@property (nonatomic, assign) BOOL webDAVShouldSavePass;
@property (nonatomic, assign) BOOL webDAVShouldTrustAllSSL;
@end

@implementation TPWSettings

static TPWSettings *sharedInstance = nil;

+ (TPWSettings *)sharedInstance {
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
		[sharedInstance loadFromUserDefaults];
	});
	
	return sharedInstance;
}

- (void)loadFromUserDefaults {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	
	if (![userDefaults objectForKey:kTPWSettingsSimpleSearchKey]) {
		self.simpleSearch = kTPWSettingsSimpleSearchDefaultValue;
	} else {
		self.simpleSearch = [userDefaults boolForKey:kTPWSettingsSimpleSearchKey];
	}
	
	if (![userDefaults objectForKey:kTPWSettingsAutoLockTimeIntervalKey]) {
		self.autoLockTimeInterval = kTPWSettingsAutoLockDefaultValue;
	} else {
		self.autoLockTimeInterval = [userDefaults doubleForKey:kTPWSettingsAutoLockTimeIntervalKey];
	}
	
	if (![userDefaults objectForKey:kTPWSettingsClearClipboardTimeIntervalKey]) {
		self.clearClipboardTimeInterval = kTPWSettingsClearClipboardDefaultValue;
	} else {
		self.clearClipboardTimeInterval = [userDefaults doubleForKey:kTPWSettingsClearClipboardTimeIntervalKey];
	}
	
	if (![userDefaults objectForKey:kTPWSettingsConcealPasswordsKey]) {
		self.concealPasswords = kTPWSettingsConcealPasswordsDefaultValue;
	} else {
		self.concealPasswords = [userDefaults boolForKey:kTPWSettingsConcealPasswordsKey];
	}
	
	self.webDAVUrl = [userDefaults objectForKey:kTPWSettingsWebDAVUrlKey];
	self.webDAVUser = [userDefaults objectForKey:kTPWSettingsWebDAVUserKey];
	self.webDAVShouldSavePass = [userDefaults boolForKey:kTPWSettingsWebDAVShouldSavePassKey];
	self.webDAVShouldTrustAllSSL = [userDefaults boolForKey:kTPWSettingsWebDAVShouldTrustAllSSLKey];
}

- (void)saveToUserDefaults {
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:self.simpleSearch forKey:kTPWSettingsSimpleSearchKey];
	[userDefaults setDouble:self.autoLockTimeInterval forKey:kTPWSettingsAutoLockTimeIntervalKey];
	[userDefaults setDouble:self.clearClipboardTimeInterval forKey:kTPWSettingsClearClipboardTimeIntervalKey];
	[userDefaults setBool:self.concealPasswords forKey:kTPWSettingsConcealPasswordsKey];
	[userDefaults setObject:self.webDAVUrl forKey:kTPWSettingsWebDAVUrlKey];
	[userDefaults setObject:self.webDAVUser forKey:kTPWSettingsWebDAVUserKey];
	[userDefaults setBool:self.webDAVShouldSavePass forKey:kTPWSettingsWebDAVShouldSavePassKey];
	[userDefaults setBool:self.webDAVShouldTrustAllSSL forKey:kTPWSettingsWebDAVShouldTrustAllSSLKey];
	[userDefaults synchronize];
}

- (void)resetUserDefaults {
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	[[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
	[[FXKeychain defaultKeychain] removeObjectForKey:kTPWSettingsWebDAVPassKey];
	[self loadFromUserDefaults];
}

#pragma mark - convencience methods

+ (void)setSimpleSearch:(BOOL)simpleSearch {
	[[TPWSettings sharedInstance] setSimpleSearch:simpleSearch];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (BOOL)simpleSearch {
	return [[TPWSettings sharedInstance] simpleSearch];
}

+ (void)setAutoLockTimeInterval:(NSTimeInterval)autoLockTimeInterval {
	[[TPWSettings sharedInstance] setAutoLockTimeInterval:autoLockTimeInterval];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (NSTimeInterval)autoLockTimeInterval {
	return [[TPWSettings sharedInstance] autoLockTimeInterval];
}

+ (void)setClearClipboardTimeInterval:(NSTimeInterval)clearClipboardTimeInterval {
	[[TPWSettings sharedInstance] setClearClipboardTimeInterval:clearClipboardTimeInterval];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (NSTimeInterval)clearClipboardTimeInterval {
	return [[TPWSettings sharedInstance] clearClipboardTimeInterval];
}

+ (void)setConcealPasswords:(BOOL)concealPasswords {
	[[TPWSettings sharedInstance] setConcealPasswords:concealPasswords];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (BOOL)concealPasswords {
	return [[TPWSettings sharedInstance] concealPasswords];
}

+ (void)setWebDAVUrl:(NSString *)webDAVUrl {
	[[TPWSettings sharedInstance] setWebDAVUrl:webDAVUrl];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (NSString *)webDAVUrl {
	return [[TPWSettings sharedInstance] webDAVUrl];
}

+ (void)setWebDAVUser:(NSString *)webDAVUser {
	[[TPWSettings sharedInstance] setWebDAVUser:webDAVUser];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (NSString *)webDAVUser {
	return [[TPWSettings sharedInstance] webDAVUser];
}

+ (void)setWebDAVPass:(NSString *)webDAVPass {
	if (webDAVPass.length > 0) {
		[[FXKeychain defaultKeychain] setObject:webDAVPass forKey:kTPWSettingsWebDAVPassKey];
	} else if ([[FXKeychain defaultKeychain] objectForKey:kTPWSettingsWebDAVPassKey]) {
		[[FXKeychain defaultKeychain] removeObjectForKey:kTPWSettingsWebDAVPassKey];
	}
}

+ (NSString *)webDAVPass {
	return [[FXKeychain defaultKeychain] objectForKey:kTPWSettingsWebDAVPassKey];
}

+ (void)setWebDAVShouldSavePass:(BOOL)webDAVShouldSavePass {
	[[TPWSettings sharedInstance] setWebDAVShouldSavePass:webDAVShouldSavePass];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (BOOL)webDAVShouldSavePass {
	return [[TPWSettings sharedInstance] webDAVShouldSavePass];
}

+ (void)setWebDAVShouldTrustAllSSL:(BOOL)webDAVShouldTrustAllSSL {
	[[TPWSettings sharedInstance] setWebDAVShouldTrustAllSSL:webDAVShouldTrustAllSSL];
	[[TPWSettings sharedInstance] saveToUserDefaults];
}

+ (BOOL)webDAVShouldTrustAllSSL {
	return [[TPWSettings sharedInstance] webDAVShouldTrustAllSSL];
}

@end
