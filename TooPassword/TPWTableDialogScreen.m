//
//  TPWTableDialogScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/25/13.
//
//

#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"

#import "TPWTableDialogScreen.h"
#import "TPWModalDialogNavigationController.h"
#import "TPWTableDialogHeaderView.h"
#import "TPWTableDialogFooterView.h"

@implementation TPWTableDialogScreen

#pragma mark - ui events

- (void)popViewControllerWithAnimation {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)dismissDialogScreenAnimated:(BOOL)animated {
	NSAssert([self.navigationController isKindOfClass:TPWModalDialogNavigationController.class], @"dialog screen must be presented inside of TPWModalDialogNavigationController");
	UIViewController *rootViewController = [self.navigationController presentingViewController];
	[rootViewController dismissViewControllerAnimated:animated completion:nil];
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

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSAssert(false, @"Overwrite this method.");
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(false, @"Overwrite this method.");
	return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if ([self tableView:tableView titleForHeaderInSection:section]) {
		UIView *headerView = [self tableView:tableView viewForHeaderInSection:section];
		UILabel *label = [headerView.subviews firstObject];
		CGFloat offset = (section == 0) ? 32.0 : 12.0;
		return label.frame.size.height + offset;
	}
	return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	if ([self tableView:tableView titleForFooterInSection:section]) {
		UIView *footerView = [self tableView:tableView viewForFooterInSection:section];
		UILabel *label = [footerView.subviews firstObject];
		return label.frame.size.height + 21.0;
	}
	return 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (![self tableView:tableView titleForHeaderInSection:section]) {
		return nil;
	}
	
	NSString *title = [self tableView:tableView titleForHeaderInSection:section];
	UIView *headerView = [[TPWTableDialogHeaderView alloc] initWithTitle:title section:section];
	[headerView layoutIfNeeded];
	return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	if (![self tableView:tableView titleForFooterInSection:section]) {
		return nil;
	}
	
	NSString *title = [self tableView:tableView titleForFooterInSection:section];
	TPWTableDialogFooterView *footerView = [[TPWTableDialogFooterView alloc] initWithTitle:title];
	[footerView layoutIfNeeded];
	return footerView;
}

#pragma mark - viewcontroller delegate stuff

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
	}
	
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = [UIColor tpwBackgroundColor];
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
