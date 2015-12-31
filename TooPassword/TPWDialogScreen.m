//
//  TPWDialogScreen.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWDialogScreen.h"
#import "TPWModalDialogNavigationController.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"

@implementation TPWDialogScreen

#pragma mark - ui events

- (void)popViewControllerWithAnimation {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissDialogScreenAnimated:(BOOL)animated {
	NSAssert([self.navigationController isKindOfClass:TPWModalDialogNavigationController.class], @"dialog screen must be presented inside of TPWModalDialogNavigationController");
	UIViewController *rootViewController = [self.navigationController presentingViewController];
	[rootViewController dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - lifecycle

- (id)initWithUniversalNibName:(NSString*)universalNibName {
	NSString *nibPostfix = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? @"_iPad" : @"_iPhone";
	NSString *nibName = [universalNibName stringByAppendingString:nibPostfix];
	if (self = [super initWithNibName:nibName bundle:nil]) {
		
	}
	return self;
}

#pragma mark - design

- (void)setTitle:(NSString *)title {
	[super setTitle:title];
	
	UILabel *label = (UILabel *)self.navigationItem.titleView;
	if (!label) {
		label = [[UILabel alloc] initWithFrame:CGRectZero];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont tpwHeadlineFont];
		if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
			label.shadowColor = [UIColor tpwShadowColor];
			label.shadowOffset = CGSizeMake(0.0, 1.0);
		}
		label.textColor = [UIColor whiteColor];
		self.navigationItem.titleView = label;
	}
	label.text = title;
	[label sizeToFit];
}

#pragma mark - viewcontroller delegate stuff

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
	}
	
	self.view.backgroundColor = [UIColor tpwBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([TPWiOSVersions isLessThanVersion:@"7.0"] && [self.navigationController.viewControllers firstObject] != self && !self.navigationItem.hidesBackButton) {
		UIViewController *precedingViewController = self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2];
		NSString *backButtonTitle = precedingViewController.title ? : NSLocalizedString(@"ui.common.back", @"back");
		UIBarButtonItem *customBackButton = [TPWBarButtonItem tpwBackBarButtonWithTitle:backButtonTitle target:self action:@selector(popViewControllerWithAnimation)];
		self.navigationItem.leftBarButtonItem = customBackButton;
	}
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
