//
//  TPWModalDialogNavigationController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWModalDialogNavigationController.h"
#import "TPWWelcomeScreen.h"
#import "TPWUnlockScreen.h"
#import "TPWSettingsScreen.h"

@implementation TPWModalDialogNavigationController

- (id)initWithDialog:(UIViewController*)dialog {
	if (self = [super initWithRootViewController:dialog]) {
		
	}
	return self;
}

- (id)initWithWelcomeScreen {
	return [self initWithDialog:[[TPWWelcomeScreen alloc] init]];
}

- (id)initWithUnlockScreen {
	return [self initWithDialog:[[TPWUnlockScreen alloc] init]];
}

- (id)initWithSettingsScreen {
	return [self initWithDialog:[[TPWSettingsScreen alloc] init]];
}

#pragma mark - viewcontroller delegate stuff

- (BOOL)disablesAutomaticKeyboardDismissal {
	return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		? YES //iPad
		: interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown; //iPhone
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		? UIInterfaceOrientationMaskAll //iPad
		: UIInterfaceOrientationMaskAllButUpsideDown; //iPhone
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.interfaceOrientation;
}

@end
