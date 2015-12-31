//
//  TPWAppDelegate.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <DropboxSDK/DropboxSDK.h>
#import "UIColor+TPWColors.h"
#import "TPWConstants.h"
#import "TPWiOSVersions.h"
#import "TPWFileUtil.h"
#import "TPWClipboard.h"
#import "TPWSettings.h"

#import "TPWAppDelegate.h"
#import "TPWRootSplitViewController.h"
#import "TPWRootNavigationController.h"
#import "TPWModalDialogNavigationController.h"

#import "TPWDecryptor.h"
#import "TPW1PasswordRepository.h"
#import "TPWKeychainChangeNotifier.h"

#import "TPWDialogScreen.h"
#import "TPWUnlockScreen.h"
#import "TPWWelcomeScreen.h"
#import "TPWSettingsScreen.h"

#import "TPWSharedDocumentImportPreparer.h"

#ifdef FREE_VERSION
#import "TPWRootBannerViewController.h"
#endif

#ifndef FREE_VERSION
NSString *const kTPWDropboxAppKey = @"<INSERT_DROPBOX_APP_KEY_FOR_FREE_VERSION>";
NSString *const kTPWDropboxAppSecret = @"<INSERT_DROPBOX_APP_SECRET_FOR_FREE_VERSION>";
#else
NSString *const kTPWDropboxAppKey = @"<INSERT_DROPBOX_APP_KEY>";
NSString *const kTPWDropboxAppSecret = @"<INSERT_DROPBOX_APP_SECRET>";
#endif

typedef NS_ENUM(NSUInteger, TPWFastForwardMode) {
	TPWFastForwardModeNone,
	TPWFastForwardModeDropbox,
	TPWFastForwardModeiTunes
};

@interface TPWAppDelegate () <DBSessionDelegate>
@property (nonatomic, strong) UIImageView *splashScreen;
@property (nonatomic, strong) NSDate *resignActiveDate;
@property (nonatomic, assign) TPWFastForwardMode fastForwardWhenBecomingActive;
@end

@implementation TPWAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Dropbox
	DBSession* dbSession = [[DBSession alloc] initWithAppKey:kTPWDropboxAppKey appSecret:kTPWDropboxAppSecret root:kDBRootDropbox];
	[DBSession setSharedSession:dbSession];
	[dbSession setDelegate:self];

	// Sync notifications
	[[TPWKeychainChangeNotifier sharedInstance] registerSyncNotifications];

	// Views and Windows
	self.rootViewController = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad
							  ? [[TPWRootSplitViewController alloc] init] //iPad
							  : [[TPWRootNavigationController alloc] initWithItemList]; //iPhone

	self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	if ([self.window respondsToSelector:@selector(tintColor)]) {
		self.window.tintColor = [UIColor tpwOrangeColor];
	}

#ifdef FREE_VERSION
	TPWRootBannerViewController *rootBannerViewController = [[TPWRootBannerViewController alloc] initWithChildController:self.rootViewController];
	self.window.rootViewController = rootBannerViewController;
#else
	self.window.rootViewController = self.rootViewController;
#endif
	[self.window makeKeyAndVisible];

	// Status Bar
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
	}

	// initialize resign active date (ensure isAutolockTimeIntervalExpired returns true on startup)
	self.resignActiveDate = [NSDate distantPast];
	self.fastForwardWhenBecomingActive = TPWFastForwardModeNone;

	// show modal dialog
	[self ensureModalDialogForCurrentAppStateIsPresented];

	// Splash screen
	if ([self splashScreenCanBeShown]) {
		[self showSplashScreen];
	}

 	return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	// Dropbox
	if ([[DBSession sharedSession] handleOpenURL:url]) {
		if ([[DBSession sharedSession] isLinked]) {
			[self wipeAll];
			if (application.applicationState == UIApplicationStateActive) {
				[self ensureModalDialogForCurrentAppStateIsPresented];
				[self fastForwardToDropboxImportScreen];
			} else {
				//defer showing import screen until window is visible
				self.fastForwardWhenBecomingActive = TPWFastForwardModeDropbox;
			}
			[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
		}
		return YES;
	}

	// Import document from 3rd party app
	if (url && [TPWSharedDocumentImportPreparer prepareImportFromUrl:url]) {
		self.fastForwardWhenBecomingActive = TPWFastForwardModeiTunes;
		return YES;
	}

	return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// show unlock screen
	if ([TPWSettings autoLockTimeInterval] == kTPWSettingsAutoLockTimeIntervalInstant) {
		[self wipeAll];
		[self ensureModalDialogForCurrentAppStateIsPresented];
	}

	// schedule autolock and clear clipboard and stop thinking
	self.resignActiveDate = [NSDate date];
	[[TPWClipboard sharedClipboard] scheduleClipboardClearTask];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	if (self.splashScreen) {
		[self animateSplashScreen];
	}

	// show correct screen
	if ([self isAutolockTimeIntervalExpired]) {
		[self ensureModalDialogForCurrentAppStateIsPresented];
	}
	if (self.fastForwardWhenBecomingActive == TPWFastForwardModeDropbox) {
		[self ensureModalDialogForCurrentAppStateIsPresented];
		[self fastForwardToDropboxImportScreen];
	} else if (self.fastForwardWhenBecomingActive == TPWFastForwardModeiTunes) {
		[self ensureModalDialogForCurrentAppStateIsPresented];
		[self fastForwardToiTunesImportScreen];
	}

	// clear clipboard task and start thinking
	[[TPWClipboard sharedClipboard] cancelClipboardClearTask];
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	if ([[TPWDecryptor sharedInstance] isUnlocked]) {
		[self showSplashScreen];
	}
}

#pragma mark -
#pragma mark DBSessionDelegate

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId {
	[session linkFromController:self.rootViewController];
}

#pragma mark -
#pragma mark Locking

- (void)wipeAll {
	[[TPWDecryptor sharedInstance] wipeMasterKeys];
	[[TPW1PasswordRepository sharedInstance] wipeData];
	[self.rootViewController wipeScreenAnimated:NO];
}

- (BOOL)isAutolockTimeIntervalExpired {
	NSTimeInterval timeIntervalDifference = [[NSDate date] timeIntervalSinceDate:self.resignActiveDate];
	NSTimeInterval autoLockTimeInterval = [TPWSettings autoLockTimeInterval];
	return timeIntervalDifference > autoLockTimeInterval;
}

#pragma mark -
#pragma mark Modal dialogs

- (void)ensureModalDialogForCurrentAppStateIsPresented {
	TPWDialogScreen *modalDialogRoot = [self rootViewControllerForModalDialogs];
	TPWModalDialogNavigationController *modalNavCtrl = [[TPWModalDialogNavigationController alloc] initWithDialog:modalDialogRoot];
	[self.rootViewController presentModalDialog:modalNavCtrl animated:NO];
}

- (void)fastForwardToDropboxImportScreen {
	TPWModalDialogNavigationController *modalNavCtrl = (TPWModalDialogNavigationController*)self.rootViewController.presentedViewController;
	NSAssert([modalNavCtrl isKindOfClass:TPWModalDialogNavigationController.class], @"can only be used if presenting a TPWModalDialogNavigationController");
	TPWDialogScreen *currentModalDialogRoot = (TPWDialogScreen*)[modalNavCtrl topViewController];
	if ([currentModalDialogRoot isKindOfClass:TPWWelcomeScreen.class]) {
		//dropbox dir listing
		TPWWelcomeScreen *welcomScreen = (TPWWelcomeScreen*)currentModalDialogRoot;
		[welcomScreen presentDropboxImporter:self];
	} else if ([currentModalDialogRoot isKindOfClass:TPWUnlockScreen.class]) {
		//show settings screen before dropbox dir listing
		TPWSettingsScreen *settingsScreen = [[TPWSettingsScreen alloc] initWithDoneButtonShown:NO];
		[modalNavCtrl pushViewController:settingsScreen animated:NO];
		[settingsScreen presentDropboxImporter];
	}
	self.fastForwardWhenBecomingActive = TPWFastForwardModeNone;
}

- (void)fastForwardToiTunesImportScreen {
	TPWModalDialogNavigationController *modalNavCtrl = (TPWModalDialogNavigationController*)self.rootViewController.presentedViewController;
	NSAssert([modalNavCtrl isKindOfClass:TPWModalDialogNavigationController.class], @"can only be used if presenting a TPWModalDialogNavigationController");
	TPWDialogScreen *currentModalDialogRoot = (TPWDialogScreen*)[modalNavCtrl topViewController];
	if ([currentModalDialogRoot isKindOfClass:TPWWelcomeScreen.class]) {
		//itunes dir listing
		TPWWelcomeScreen *welcomScreen = (TPWWelcomeScreen*)currentModalDialogRoot;
		[welcomScreen presentiTunesImporter:self];
	} else if ([currentModalDialogRoot isKindOfClass:TPWUnlockScreen.class]) {
		//show settings screen before itunes dir listing
		TPWSettingsScreen *settingsScreen = [[TPWSettingsScreen alloc] initWithDoneButtonShown:NO];
		[modalNavCtrl pushViewController:settingsScreen animated:NO];
		[settingsScreen presentiTunesImporter];
	}
	self.fastForwardWhenBecomingActive = TPWFastForwardModeNone;
}

- (TPWDialogScreen*)rootViewControllerForModalDialogs {
	return [TPWFileUtil keychainIsValid] ? [[TPWUnlockScreen alloc] init] : [[TPWWelcomeScreen alloc] init];
}

#pragma mark -
#pragma mark Splash screen

- (BOOL)splashScreenCanBeShown {
	return !([TPWiOSVersions isLessThanVersion:@"6.0"] && [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void)showSplashScreen {
	if (self.splashScreen) {
		return;
	}
	self.splashScreen = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self splashScreenImageName]]];
	self.splashScreen.transform = [self transformForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
	self.splashScreen.center = self.rootViewController.view.center;
	[self.window addSubview:self.splashScreen];
}

- (void)animateSplashScreen {
	if (!self.splashScreen) {
		[self showSplashScreen];
	}
	[UIView animateWithDuration:0.3 animations:^{
		self.splashScreen.alpha = 0.0;
		self.splashScreen.transform = CGAffineTransformScale(self.splashScreen.transform, 2.0, 2.0);
	} completion:^(BOOL finished) {
		[self.splashScreen removeFromSuperview];
		self.splashScreen = nil;
	}];
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation {
	switch (orientation) {
		case UIInterfaceOrientationLandscapeLeft:
			return CGAffineTransformMakeRotation(-M_PI_2);
		case UIInterfaceOrientationLandscapeRight:
			return CGAffineTransformMakeRotation(M_PI_2);
		case UIInterfaceOrientationPortraitUpsideDown:
			return CGAffineTransformMakeRotation(M_PI);
		case UIInterfaceOrientationPortrait:
		default:
			return CGAffineTransformMakeRotation(0.0);
	}
}

- (NSString *)splashScreenImageName {
	NSString *splashScreenImageName = @"Default"; // basename

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if ([[UIScreen mainScreen] bounds].size.height == 568.0) {
			splashScreenImageName = [splashScreenImageName stringByAppendingString:@"-568h"]; // iphone widescreen
		}
	} else {
		if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
			if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
				splashScreenImageName = [splashScreenImageName stringByAppendingString:@"-768h"]; // with status bar
			}
			splashScreenImageName = [splashScreenImageName stringByAppendingString:@"-Landscape"]; // landscape
		} else {
			if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
				splashScreenImageName = [splashScreenImageName stringByAppendingString:@"-1024h"]; // with status bar
			}
			splashScreenImageName = [splashScreenImageName stringByAppendingString:@"-Portrait"]; // portrait
		}
	}

	return splashScreenImageName;
}

@end
