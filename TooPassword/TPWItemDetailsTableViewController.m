//
//  TPWItemDetailsTableViewController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWItemDetailsTableViewController.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"
#import "TPWBarButtonItem.h"
#import "TPWClipboard.h"
#import "TPWSettings.h"

NSString *const kTPWItemDetailTableKeyPathOfConcealPasswordsSetting = @"concealPasswords";

@interface TPWItemDetailsTableViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) TPW1PasswordItemActions *actionsForSelectedItem;
@end

@implementation TPWItemDetailsTableViewController

- (id)initWithPasswordItem:(TPW1PasswordItem*)item {
	if (self = [self initWithStyle:UITableViewStyleGrouped]) {
		self.passwordItem = item;
		self.title = item.title;
	}
	return self;
}

- (id)initWithStyle:(UITableViewStyle)style {
	if (self = [super initWithStyle:style]) {
		[[TPWSettings sharedInstance] addObserver:self forKeyPath:kTPWItemDetailTableKeyPathOfConcealPasswordsSetting options:NSKeyValueObservingOptionNew context:nil];
	}
	return self;
}

- (void)dealloc {
	[[TPWSettings sharedInstance] removeObserver:self forKeyPath:kTPWItemDetailTableKeyPathOfConcealPasswordsSetting];
	//[super dealloc]; done by ARC
}

- (void)setPasswordItem:(TPW1PasswordItem *)passwordItem {
	//store weak reference:
	_passwordItem = passwordItem;
	
	//configure data source:
	[passwordItem determineIndexesOfObfuscatedRows];
	self.tableView.dataSource = passwordItem;
	
	//update ui:
	self.title = passwordItem.title;
	[self.tableView reloadData];
}

#pragma mark - setting changes regarding concealed passwords

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	if (object == [TPWSettings sharedInstance] && [keyPath isEqualToString:kTPWItemDetailTableKeyPathOfConcealPasswordsSetting]) {
		[self reloadRowsWithIndexes:self.passwordItem.indexesOfPasswordRows];
	}
}

- (void)reloadRowsWithIndexes:(NSIndexSet*)indexes {
	NSMutableArray *affectedRows = [NSMutableArray arrayWithCapacity:indexes.count];
	[indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		[affectedRows addObject:[NSIndexPath indexPathForRow:idx inSection:0]];
	}];
	[self.tableView reloadRowsAtIndexPaths:affectedRows withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - ui events

- (void)popViewControllerWithAnimation {
	[self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return [self.passwordItem preferredHeightForHeaderInSection:section inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
	return [self.passwordItem preferredHeightForFooterInSection:section inTableView:tableView];
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return [self.passwordItem preferredViewForHeaderInSection:section inTableView:tableView];
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	return [self.passwordItem preferredViewForFooterInSection:section inTableView:tableView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [self.passwordItem preferredHeightForRowAtIndexPath:indexPath inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	self.actionsForSelectedItem = [self.passwordItem actionsForRowInTable:tableView atIndexPath:indexPath];
	UIActionSheet *actionSheet = [self.actionsForSelectedItem actionSheetWithDelegate:self];
	
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[actionSheet showFromRect:cell.contentView.frame inView:cell animated:YES];
}

#pragma mark - copy action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	[self.actionsForSelectedItem actionSheet:actionSheet clickedButtonAtIndex:buttonIndex];
	self.actionsForSelectedItem = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - lifecylce

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
	}
	
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = [UIColor tpwBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
			NSString *backButtonTitle = NSLocalizedString(@"ui.common.back", @"back");
			UIBarButtonItem *customBackButton = [TPWBarButtonItem tpwBackBarButtonWithTitle:backButtonTitle target:self action:@selector(popViewControllerWithAnimation)];
			self.navigationItem.leftBarButtonItem = customBackButton;
		}
	} else {
		//don't show back button on iPad
		self.navigationItem.hidesBackButton = YES;
	}
}

#pragma mark - viewcontroller delegate stuff

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		? YES //iPad
		: (interfaceOrientation == UIInterfaceOrientationPortrait); //iPhone
}

- (BOOL)shouldAutorotate {
	return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (NSUInteger)supportedInterfaceOrientations {
	return ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
		? UIInterfaceOrientationMaskAll //iPad
		: UIInterfaceOrientationMaskPortrait; //iPhone
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
	return self.interfaceOrientation;
}

@end
