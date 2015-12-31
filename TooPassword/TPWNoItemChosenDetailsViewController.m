//
//  TPWNoItemChosenDetailsViewController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 25.01.13.
//
//

#import "TPWNoItemChosenDetailsViewController.h"
#import "UIColor+TPWColors.h"

@implementation TPWNoItemChosenDetailsViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
	}
	
	self.view.backgroundColor = [UIColor tpwBackgroundColor];
	
	//stamp view
	UIImageView *stamp = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BackgroundStamp"]];
	stamp.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
	stamp.frame = CGRectMake((CGRectGetWidth(self.view.bounds) - CGRectGetWidth(stamp.frame)) / 2.0,
							 (CGRectGetHeight(self.view.bounds) - CGRectGetHeight(stamp.frame)) / 2.0,
							 CGRectGetWidth(stamp.frame),
							 CGRectGetHeight(stamp.frame));
	[self.view addSubview:stamp];
}

#pragma mark - viewcontroller delegate stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad, @"this view should only be used on the iPad");
	return YES;
}

- (BOOL)shouldAutorotate {
	NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad, @"this view should only be used on the iPad");
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad, @"this view should only be used on the iPad");
	return UIInterfaceOrientationMaskAll; //iPad
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.interfaceOrientation;
}

@end
