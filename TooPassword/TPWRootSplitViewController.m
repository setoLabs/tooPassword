//
//  TPWRootSplitViewController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWRootSplitViewController.h"
#import "TPWNoItemChosenDetailsViewController.h"

@interface TPWRootSplitViewController ()
@property (nonatomic, strong) TPWNoItemChosenDetailsViewController *noItemChosenViewController;
@property (nonatomic, strong) UINavigationController *itemListNavigation;
@property (nonatomic, strong) UINavigationController *itemDetailsNavigation;
@end

@implementation TPWRootSplitViewController

#pragma mark - root view controller stuff

- (void)wipeScreenAnimated:(BOOL)animated {
	[self refreshItemListAnimated:animated];
}

- (void)refreshItemListAnimated:(BOOL)animated  {
	self.itemList.selectedItem = nil;
	self.itemDetails.passwordItem = nil;
	[self.itemList reloadPasswordsAnimated:animated];
	[self.itemDetailsNavigation popToRootViewControllerAnimated:animated];
}

- (void)showDetailsOfItem:(TPW1PasswordItem*)item {
	self.itemList.selectedItem = item;
	self.itemDetails.passwordItem = item;
	if (self.itemDetailsNavigation.topViewController == self.noItemChosenViewController) {
		[self.itemDetailsNavigation pushViewController:self.itemDetails animated:YES];
	}
}

- (void)presentModalDialog:(TPWModalDialogNavigationController*)modalDialogNavigationController animated:(BOOL)animated {
	UINavigationController *presentedNavigationController = (UINavigationController *)self.presentedViewController;
	//don't present anything, if it's the same dialog
	if (![presentedNavigationController.topViewController isKindOfClass:[modalDialogNavigationController.topViewController class]]) {
		//present view controller, if not already another dialog is presented
		if (![self.presentedViewController isKindOfClass:TPWModalDialogNavigationController.class]) {
			modalDialogNavigationController.modalPresentationStyle = UIModalPresentationFormSheet;
			[self presentViewController:modalDialogNavigationController animated:animated completion:nil];
		} else {
			UIViewController *modalDialog = modalDialogNavigationController.topViewController;
			modalDialog.navigationItem.hidesBackButton = YES;
			[presentedNavigationController pushViewController:modalDialog animated:animated];
		}
	}
}

#pragma mark - lifecycle

- (id)init {
	NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad, @"TPWRootSplitViewController must only be used on iPads");
	if (self = [super init]) {
		self.itemList = [[TPWItemListTableViewController alloc] init];
		self.itemDetails = [[TPWItemDetailsTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
		self.noItemChosenViewController = [[TPWNoItemChosenDetailsViewController alloc] init];
		
		self.itemListNavigation = [[TPWNavigationController alloc] initWithRootViewController:self.itemList];
		self.itemDetailsNavigation = [[TPWNavigationController alloc] initWithRootViewController:self.noItemChosenViewController];
		self.viewControllers = @[self.itemListNavigation, self.itemDetailsNavigation];
		self.delegate = self;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	
	//shitty view from iOS 7 is shitty
	for (UIView *subview in self.view.subviews) {
		if ([subview isMemberOfClass:UIView.class]) {
			subview.backgroundColor = [UIColor clearColor];
		}
	}
}

#pragma mark - viewcontroller delegate stuff

- (BOOL)splitViewController:(UISplitViewController *)svc shouldHideViewController:(UIViewController *)vc inOrientation:(UIInterfaceOrientation)orientation {
	return NO; //show master AND detail view controller in both ui orientations
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (BOOL)shouldAutorotate {
	return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.interfaceOrientation;
}

@end
