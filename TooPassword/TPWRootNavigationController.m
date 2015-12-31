//
//  TPWRootNavigationController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWRootNavigationController.h"

@implementation TPWRootNavigationController

#pragma mark - root view controller stuff

- (void)wipeScreenAnimated:(BOOL)animated {
	[self popToRootViewControllerAnimated:animated];
	[self refreshItemListAnimated:animated];
}

- (void)refreshItemListAnimated:(BOOL)animated {
	self.itemList.selectedItem = nil;
	self.itemDetails.passwordItem = nil;
	[self.itemList reloadPasswordsAnimated:animated];
}

- (void)showDetailsOfItem:(TPW1PasswordItem*)item {
	self.itemList.selectedItem = item;
	self.itemDetails = [[TPWItemDetailsTableViewController alloc] initWithPasswordItem:item];
	[self pushViewController:self.itemDetails animated:YES];
}

- (void)presentModalDialog:(TPWModalDialogNavigationController*)modalDialogNavigationController animated:(BOOL)animated {
	UINavigationController *presentedNavigationController = (UINavigationController *)self.presentedViewController;
	//don't present anything, if it's the same dialog
	if (![presentedNavigationController.topViewController isKindOfClass:[modalDialogNavigationController.topViewController class]]) {
		//present view controller, if not already another dialog is presented
		if (![self.presentedViewController isKindOfClass:TPWModalDialogNavigationController.class]) {
			[modalDialogNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
			[self presentViewController:modalDialogNavigationController animated:animated completion:nil];
		} else {
			UIViewController *modalDialog = modalDialogNavigationController.topViewController;
			
			//try "pop"
			for (UIViewController *viewController in presentedNavigationController.viewControllers) {
				if ([viewController isKindOfClass:modalDialog.class]) {
					[presentedNavigationController popToViewController:viewController animated:animated];
					return;
				}
			}
			
			//else "push"
			modalDialog.navigationItem.hidesBackButton = YES;
			[presentedNavigationController pushViewController:modalDialog animated:animated];
		}
	}
}

#pragma mark - lifecycle

- (id)initWithItemList {
	NSAssert([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone, @"TPWRootNavigationController must only be used on iPhones");
	TPWItemListTableViewController *itemList = [[TPWItemListTableViewController alloc] init];
	if (self = [super initWithRootViewController:itemList]) {
		self.itemList = itemList;
	}
	return self;
}

#pragma mark - viewcontroller delegate stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
	return NO;
}

- (NSUInteger)supportedInterfaceOrientations {
	return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.interfaceOrientation;
}

@end
