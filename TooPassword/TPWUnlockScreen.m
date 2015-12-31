//
//  TPWUnlockScreen.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <QuartzCore/CoreAnimation.h>

#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPWDecryptor.h"
#import "TPW1PasswordRepository.h"
#import "UIViewController+TPWSharedRootViewController.h"
#import "TPWBarButton.h"
#import "UIColor+TPWColors.h"
#import "UITextField+TPWDesign.h"
#import "TPWTextfieldButton.h"
#import "UIAlertView+TPWAlerts.h"
#import "TPWUnlockScreen.h"
#import "TPWSettingsScreen.h"
#import "TPWiOSVersions.h"

NSString *const kTPWUnlockScreenShakeAnimationKey = @"TPWUnlockScreen.shake";
CGFloat const kTPWUnlockScreenButtonPaddings = 20.0;
CGFloat const kTPWUnlockScreenButtonLeftRightMargins = 20.0;
CGFloat const kTPWUnlockScreenButtonTopBottomMargins = 8.0;

@interface TPWUnlockScreen () <UITextFieldDelegate>

@end

@implementation TPWUnlockScreen

#pragma mark - lifecycle

- (id)init {
	if (self = [super initWithUniversalNibName:@"TPWUnlockScreen"]) {
		
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *titleImageName = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? @"NavigationbarTitle-noshadow" : @"NavigationbarTitle";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleImageName]];
	
	//password field
	self.masterPasswordField.borderStyle = UITextBorderStyleNone;
	[self.masterPasswordField setTpwBackgroundImageAndCutOffRightBorder];
	self.masterPasswordField.placeholder = NSLocalizedString(@"ui.modalDialogs.unlockScreen.masterPasswordPlaceholder", @"placeholder text for master password");
	self.masterPasswordField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"LockIcon"]];
	self.masterPasswordField.leftViewMode = UITextFieldViewModeAlways;
	self.masterPasswordField.delegate = self;
	self.masterPasswordField.enablesReturnKeyAutomatically = YES;
	
	//unlock button
	[self.unlockButton setTitle:NSLocalizedString(@"ui.modalDialogs.unlockScreen.unlockButtonTitle", @"title of unlock button") forState:UIControlStateNormal];
	self.unlockButton.enabled = NO;
	
	//password hint label
	self.passwordHintLabel.textColor = [UIColor tpwDarkGrayColor];
	if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
		self.passwordHintLabel.shadowColor = [UIColor whiteColor];
		self.passwordHintLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	}
	
	// Settings button on the right.
	UIButton *settingsButton = [TPWBarButton tpwBarButtonWithTarget:self action:@selector(presentSettingsDialog)];
	settingsButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		[settingsButton setImage:[UIImage imageNamed:@"SettingsIcon-noshadow"] forState:UIControlStateNormal];
	} else {
		[settingsButton setImage:[UIImage imageNamed:@"SettingsIcon_active"] forState:UIControlStateNormal];
		[settingsButton setImage:[UIImage imageNamed:@"SettingsIcon_highlighted"] forState:UIControlStateHighlighted];
		[settingsButton setImage:[UIImage imageNamed:@"SettingsIcon_disabled"] forState:UIControlStateDisabled];
	}
	settingsButton.accessibilityLabel = NSLocalizedString(@"voiceOver.button.settings.label", @"voice over - button settings label");
	UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
	self.navigationItem.rightBarButtonItem = settingsBarButton;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//when this screen is shown, make sure, all previously shown data is wiped
	[[TPWDecryptor sharedInstance] wipeMasterKeys];
	[[TPW1PasswordRepository sharedInstance] wipeData];
	BOOL animateWipe = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? animated : NO;
	[self.sharedTPWRootViewController wipeScreenAnimated:animateWipe];
	//wipe texts and labels
	self.masterPasswordField.text = nil;
	self.passwordHintLabel.text = nil;
	self.unlockButton.enabled = NO;
	//layout
	[self layoutViews];
	//check sync possibility
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
}

- (void)layoutViews {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		[self layoutViewsLandscape];
	} else {
		[self layoutViewsPortrait];
	}
}

- (void)layoutViewsPortrait {
	CGSize unlockTitleSize = [self.unlockButton.titleLabel.text sizeWithFont:self.unlockButton.titleLabel.font];
	CGFloat buttonWidth = unlockTitleSize.width + kTPWUnlockScreenButtonPaddings;
	CGFloat masterPasswordOriginY = floorf((CGRectGetMaxY(self.view.bounds) - 256.0) / 2.0);
	
	CGRect masterPasswordRect = self.masterPasswordField.frame;
	masterPasswordRect.origin.y = masterPasswordOriginY;
	masterPasswordRect.size.width = CGRectGetWidth(self.view.bounds) - kTPWUnlockScreenButtonLeftRightMargins * 2.0 - buttonWidth;
	self.masterPasswordField.frame = masterPasswordRect;
	
	CGRect unlockRect = self.unlockButton.frame;
	unlockRect.origin.x = CGRectGetMaxX(masterPasswordRect);
	unlockRect.origin.y = masterPasswordOriginY;
	unlockRect.size.width = buttonWidth;
	self.unlockButton.frame = unlockRect;
	
	CGRect passwordHintRect = self.passwordHintLabel.frame;
	passwordHintRect.origin.y = CGRectGetMaxY(masterPasswordRect) + kTPWUnlockScreenButtonTopBottomMargins;
	self.passwordHintLabel.frame = passwordHintRect;
}

- (void)layoutViewsLandscape {
	CGSize unlockTitleSize = [self.unlockButton.titleLabel.text sizeWithFont:self.unlockButton.titleLabel.font];
	CGFloat buttonWidth = unlockTitleSize.width + kTPWUnlockScreenButtonPaddings;
	CGFloat masterPasswordOriginY = floorf((CGRectGetMaxY(self.view.bounds) - 240.0) / 2.0);
	
	CGRect masterPasswordRect = self.masterPasswordField.frame;
	masterPasswordRect.origin.y = masterPasswordOriginY;
	masterPasswordRect.size.width = CGRectGetWidth(self.view.bounds) - kTPWUnlockScreenButtonLeftRightMargins * 2.0 - buttonWidth;
	self.masterPasswordField.frame = masterPasswordRect;
	
	CGRect unlockRect = self.unlockButton.frame;
	unlockRect.origin.x = CGRectGetMaxX(masterPasswordRect);
	unlockRect.origin.y = masterPasswordOriginY;
	unlockRect.size.width = buttonWidth;
	self.unlockButton.frame = unlockRect;
	
	CGRect passwordHintRect = self.passwordHintLabel.frame;
	passwordHintRect.origin.y = CGRectGetMaxY(masterPasswordRect) + kTPWUnlockScreenButtonTopBottomMargins;
	self.passwordHintLabel.frame = passwordHintRect;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.masterPasswordField becomeFirstResponder];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self layoutViews];
}

#pragma mark - ui events

- (IBAction)unlock:(UITextField *)sender {
	BOOL success = [[TPWDecryptor sharedInstance] decryptMasterKeysWithPassword:self.masterPasswordField.text];
	if (success) {
		[[TPW1PasswordRepository sharedInstance] loadPasswordsWithError:NULL]; //ignore errors
		[[TPW1PasswordRepository sharedInstance] decryptPasswords];
		BOOL animateLoad = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
		[[self sharedTPWRootViewController] refreshItemListAnimated:animateLoad];
		
		//stop shake animation
		[self.viewToShake.layer removeAnimationForKey:kTPWUnlockScreenShakeAnimationKey];
		
		//voiceover: keychain unlocked
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"voiceOver.notification.keychainUnlocked", @"voice over - keychain unlocked"));
		
		//check sync possibility
		[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
		
		//reveal passwords
		[self dismissDialogScreenAnimated:YES];
	} else {
		//reset password field and keep keyboard visible
		self.masterPasswordField.text = nil;
		self.unlockButton.enabled = NO;
		
		//shake animation
		[self shakeUnlockScreen];
		
		//voiceover: incorrect password
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, NSLocalizedString(@"voiceOver.notification.incorrectPassword", @"voice over - incorrect password"));
		
		//show .password.hint, if unlock fails
		NSData *passwordHintData = [NSData dataWithContentsOfFile:[[TPWFileUtil keychainPath] stringByAppendingPathComponent:kTPWPasswordHintFileName]];
		if (passwordHintData) {
			NSString *passwordHint = [[NSString alloc] initWithData:passwordHintData encoding:NSUTF8StringEncoding];
			self.passwordHintLabel.text = [NSString stringWithFormat:@"%@:\n%@",
										   NSLocalizedString(@"ui.modalDialogs.unlockScreen.passwordHint", @"unlock screen - password hint label"),
										   passwordHint];
		}
	}
}

- (IBAction)textFieldDidChange:(id)sender {
	self.unlockButton.enabled = [self textFieldHasAtLeastOneCharacter:sender];
}

- (BOOL)textFieldHasAtLeastOneCharacter:(UITextField *)textField {
	return (textField.text.length > 0);
}

- (void)presentSettingsDialog {
	TPWSettingsScreen *settingsDialog = [[TPWSettingsScreen alloc] initWithDoneButtonShown:NO];
	[self.navigationController pushViewController:settingsDialog animated:YES];
}

#pragma mark - shaking

- (UIView*)viewToShake {
	return self.navigationController.view.superview; //shake the whole modal dialog
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	[self.viewToShake.layer removeAnimationForKey:kTPWUnlockScreenShakeAnimationKey];
}

- (void)shakeUnlockScreen {
	CGPoint pos = self.viewToShake.layer.position;
	
	CGFloat shakeX = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 1.0 : 0.0;
	shakeX = (self.interfaceOrientation == UIInterfaceOrientationPortrait) ? shakeX : -shakeX;
	CGFloat shakeY = UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 1.0 : 0.0;
	shakeY = (self.interfaceOrientation == UIInterfaceOrientationLandscapeRight) ? shakeY : -shakeY;
	
	CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, pos.x, pos.y);
	CGPathAddLineToPoint(path, NULL, pos.x-22.0*shakeX, pos.y-22.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x+18.0*shakeX, pos.y+18.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x-14.0*shakeX, pos.y-14.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x+10.0*shakeX, pos.y+10.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x-6.0*shakeX, pos.y-6.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x+2.0*shakeX, pos.y+2.0*shakeY);
	CGPathAddLineToPoint(path, NULL, pos.x, pos.y);
	CGPathCloseSubpath(path);
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
	animation.path = path;
	animation.duration = 0.8f;
	
	CGPathRelease(path);
	
	[self.viewToShake.layer addAnimation:animation forKey:kTPWUnlockScreenShakeAnimationKey];
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSAssert(textField == self.masterPasswordField, @"delegate method invoked by unexpected textfield");
	if ([self textFieldHasAtLeastOneCharacter:textField]) {
		[self unlock:textField];
		return YES;
	}
	return NO;
}

@end
