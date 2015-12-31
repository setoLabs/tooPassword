//
//  TPWItemListTableViewController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "TPWItemListTableViewController.h"
#import "UIViewController+TPWSharedRootViewController.h"
#import "TPWModalDialogNavigationController.h"
#import "TPWProgressHUD.h"
#import "TPWAbstractSyncChecker.h"
#import "TPWAbstractImporter.h"
#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPW1PasswordRepository.h"
#import "TPW1PasswordRepository+Grouping.h"
#import "TPW1PasswordRepository+Filtering.h"
#import "TPW1PasswordItem.h"
#import "UIColor+TPWColors.h"
#import "TPWBarButton.h"
#import "TPWSectionHeaderView.h"
#import "TPWSectionFooterView.h"
#import "TPWPlainTableViewCell.h"
#import "TPWSearchBar.h"
#import "TPWItemListTableView.h"
#import "TPWSettings.h"
#import "TPWChangedTableSectionsUtil.h"
#import "TPWBadgedBarButton.h"
#import "TPWDecryptor.h"
#import "UIAlertView+TPWAlerts.h"
#import "TPWiOSVersions.h"

NSUInteger const kTPWItemListMinimumNumberOfRowsToDisplaySectionIndex = 50;

@interface TPWItemListTableViewController () <UISearchDisplayDelegate>
@property (nonatomic, strong) NSDictionary *groupedPasswords;
@property (nonatomic, strong) NSArray *groups;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (nonatomic, strong) TPWBadgedBarButton *resyncButton;
@property (nonatomic, strong) TPWAbstractSyncChecker *syncChecker;
@property (nonatomic, strong) TPWAbstractImporter *keychainImporter;
@end

@implementation TPWItemListTableViewController

- (id)init {
	if (self = [super init]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(checkSyncPossiblity:)
													 name:kTPWNotificationCheckSyncPossiblity
												   object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(appWillResignActive:)
													 name:UIApplicationWillResignActiveNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - ui events

- (void)presentWelcomeDialog {
	TPWModalDialogNavigationController *dialog = [[TPWModalDialogNavigationController alloc] initWithWelcomeScreen];
	
	[self.sharedTPWRootViewController presentModalDialog:dialog animated:YES];
}

- (void)presentUnlockDialog {
	TPWModalDialogNavigationController *dialog = [[TPWModalDialogNavigationController alloc] initWithUnlockScreen];
	
	[self.sharedTPWRootViewController presentModalDialog:dialog animated:YES];
}

- (void)presentSettingsDialog {
	TPWModalDialogNavigationController *dialog = [[TPWModalDialogNavigationController alloc] initWithSettingsScreen];
	
	[self.sharedTPWRootViewController presentModalDialog:dialog animated:YES];
}

#pragma mark - notifications

- (void)checkSyncPossiblity:(NSNotification *)notification {
	NSAssert([[notification name] isEqualToString:kTPWNotificationCheckSyncPossiblity], @"checkSyncPossiblity: is called from wrong notification.");
	
	//cancel here, if application is still locked.
	if (![[TPWDecryptor sharedInstance] isUnlocked]) {
		self.navigationItem.leftBarButtonItem.enabled = NO;
		self.resyncButton.showBadge = NO;
		return;
	}
	
	//otherwise checkSyncPossibility...
	self.syncChecker = [TPWAbstractSyncChecker syncChecker];
	[self.syncChecker checkSyncPossibility:^(BOOL syncIsPossible, BOOL hasChanges) {
		self.navigationItem.leftBarButtonItem.enabled = syncIsPossible;
		self.resyncButton.showBadge = hasChanges && syncIsPossible;
	}];
}

- (void)appWillResignActive:(NSNotification *)notification {
	NSAssert([[notification name] isEqualToString:UIApplicationWillResignActiveNotification], @"appWillResignActive: is called from wrong notification.");
	
	[self.keychainImporter cancel];
	[TPWProgressHUD dismiss];
}

#pragma mark - sync

- (void)startSync {
	[TPWProgressHUD showWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusLoading", @"progress hud loading status") maskType:SVProgressHUDMaskTypeBlack];
	
	self.keychainImporter = [self.syncChecker suitableImporter];
	[self.keychainImporter importKeychainAtPath:self.syncChecker.path onCompletion:^(BOOL success, NSError *error) {
		if (success) {
			[TPWProgressHUD showSuccessWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusSuccess", @"progress hud success status")];
			[self syncSuccessful];
		} else {
			[TPWProgressHUD showErrorWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusError", @"progress hud error status")];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
	} onProgress:^(CGFloat progress) {
		[TPWProgressHUD showProgress:progress status:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusLoading", @"progress hud loading status")];
	}];
}

- (void)syncSuccessful {
	if ([TPWFileUtil keychainIsValid]) {
		if (![[TPWDecryptor sharedInstance] hasEncryptionKeysFileChanged]) {
			[[TPW1PasswordRepository sharedInstance] loadPasswordsWithError:NULL]; //ignore errors
			[[TPW1PasswordRepository sharedInstance] decryptPasswords];
			[[self sharedTPWRootViewController] refreshItemListAnimated:YES];
		} else {
			[self presentUnlockDialog];
		}
	} else {
		[self presentWelcomeDialog];
	}
}

#pragma mark - lifecycle

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// iOS 7 layout
	if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
		self.edgesForExtendedLayout = UIRectEdgeNone;
	}
	
	//navigation bar
	NSString *titleImageName = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? @"NavigationbarTitle-noshadow" : @"NavigationbarTitle";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleImageName]];
	if ([self.navigationController.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
	} else {
		[self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavigationbarBackground"] forBarMetrics:UIBarMetricsDefault];
	}
	
	//setup searchbar
	CGRect searchBarFrame = CGRectMake(0.0, 0.0, 320.0, 44.0);
	TPWSearchBar *searchBar = [[TPWSearchBar alloc] initWithFrame:searchBarFrame];
	self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
	self.searchController.delegate = self;
	self.searchController.searchResultsDelegate = self;
	self.searchController.searchResultsDataSource = self;
	self.tableView.tableHeaderView = searchBar;
	
	//design stuff
	if ([self.tableView respondsToSelector:@selector(sectionIndexColor)]) {
		self.tableView.sectionIndexColor = [UIColor tpwOrangeColor];
		self.tableView.sectionIndexTrackingBackgroundColor = [[UIColor tpwLightGrayColor] colorWithAlphaComponent:0.5];
	}
	if ([self.tableView respondsToSelector:@selector(sectionIndexBackgroundColor)]) {
		self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
	}
	self.tableView.sectionIndexMinimumDisplayRowCount = kTPWItemListMinimumNumberOfRowsToDisplaySectionIndex;
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	self.tableView.backgroundView = nil;
	self.tableView.backgroundColor = [UIColor tpwTableViewCellColor];
	
	// Sync button on the left.
	self.resyncButton = [TPWBadgedBarButton tpwBarButtonWithTarget:self action:@selector(startSync)];
	self.resyncButton.frame = CGRectMake(0.0, 0.0, 30.0, 30.0);
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		[self.resyncButton setImage:[UIImage imageNamed:@"RefreshIcon-noshadow"] forState:UIControlStateNormal];
	} else {
		[self.resyncButton setImage:[UIImage imageNamed:@"RefreshIcon_active"] forState:UIControlStateNormal];
		[self.resyncButton setImage:[UIImage imageNamed:@"RefreshIcon_highlighted"] forState:UIControlStateHighlighted];
		[self.resyncButton setImage:[UIImage imageNamed:@"RefreshIcon_disabled"] forState:UIControlStateDisabled];
	}
	self.resyncButton.accessibilityLabel = NSLocalizedString(@"voiceOver.button.refresh.label", @"voice over - button refresh label");
	UIBarButtonItem *syncBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.resyncButton];
	syncBarButton.enabled = NO;
	self.navigationItem.leftBarButtonItem = syncBarButton;
	
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

#pragma mark - Searchbar

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
	if (searchString.length == 0) {
		return NO;
	}
	
	NSArray *words = [searchString componentsSeparatedByString:@" "];
	BOOL simpleSearch = [TPWSettings simpleSearch];
	self.searchResults = [[TPW1PasswordRepository sharedInstance] sortedPasswordsFilteredUsingSearchTerms:words searchTitleOnly:simpleSearch];

	//reload results:
	[controller.searchResultsTableView beginUpdates];
	[controller.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	[controller.searchResultsTableView endUpdates];
	
	//pre-selection on ipad:
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
		NSIndexPath *indexInSearchResults = [self indexPathForItemInSearchResults:self.selectedItem];
		[controller.searchResultsTableView selectRowAtIndexPath:indexInSearchResults animated:NO scrollPosition:UITableViewScrollPositionNone];
	}

	return NO; //we reload manually, thus being able to preserve the selection
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
	//design
	tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	tableView.backgroundView = nil;
	tableView.backgroundColor = [UIColor tpwTableViewCellColor];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
	NSIndexPath *indexInAlphabeticList = [self indexPathForItemInAlphabeticList:self.selectedItem];
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad && ![self.tableView.indexPathForSelectedRow isEqual:indexInAlphabeticList]) {
		[self.tableView selectRowAtIndexPath:indexInAlphabeticList animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	}
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
	[(TPWSearchBar *)controller.searchBar willBeginSearchAnimated:YES];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
	[(TPWSearchBar *)controller.searchBar willEndSearchAnimated:YES];
}

- (NSIndexPath*)indexPathForItemInAlphabeticList:(TPW1PasswordItem*)item {
	for (NSInteger section=0; section<self.groups.count; section++) {
		NSString *groupKey = self.groups[section];
		NSArray *passwordsInGroup = self.groupedPasswords[groupKey];
		for (NSInteger row=0; row<passwordsInGroup.count; row++) {
			if ([passwordsInGroup[row] isEqual:item]) {
				return [NSIndexPath indexPathForRow:row inSection:section];
			}
		}
	}
	return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
}

- (NSIndexPath*)indexPathForItemInSearchResults:(TPW1PasswordItem*)item {
	for (NSInteger row=0; row<self.searchResults.count; row++) {
		if ([self.searchResults[row] isEqual:item]) {
			return [NSIndexPath indexPathForRow:row inSection:0];
		}
	}
	return [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
}

#pragma mark - reloading

- (void)reloadPasswordsAnimated:(BOOL)animated {
	[self.searchDisplayController setActive:NO animated:animated];
	NSArray *groupsBeforeUpdate = self.groups;
	NSDictionary *groupedPasswordsBeforeUpdate = self.groupedPasswords;
	
	self.groupedPasswords = [[TPW1PasswordRepository sharedInstance] passwordsGroupedAlphabetically];
	self.groups = [self.groupedPasswords.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *group1, NSString *group2) {
		return [group1 compare:group2];
	}];
	
	if (animated && groupsBeforeUpdate != nil) {
		[TPWChangedTableSectionsUtil updateTable:self.tableView
					   byComparingSectionsBefore:groupsBeforeUpdate cellsBefore:groupedPasswordsBeforeUpdate
							   withSectionsAfter:self.groups cellsAfter:self.groupedPasswords];
	} else {
		[self.tableView reloadData];
	}
	
	if (self.tableView.indexPathForSelectedRow != nil) {
		NSIndexPath *indexInAlphabeticList = [self indexPathForItemInAlphabeticList:self.selectedItem];
		if (![self.tableView.indexPathForSelectedRow isEqual:indexInAlphabeticList]) {
			[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
			[self.tableView selectRowAtIndexPath:indexInAlphabeticList animated:animated scrollPosition:UITableViewScrollPositionMiddle];
		}
	}
}

#pragma mark - UITableViewDataSource

- (BOOL)isLastSection:(NSUInteger)section {
	return section == self.groups.count-1;
}

- (BOOL)isLastCellInSection:(NSIndexPath*)indexPath {
	NSString *key = self.groups[indexPath.section];
	NSArray *group = self.groupedPasswords[key];
	return indexPath.row >= group.count; //cells < count are normal cells
}

- (BOOL)isSplitterRow:(NSIndexPath*)indexPath {
	return ![self isLastSection:indexPath.section] && [self isLastCellInSection:indexPath];
}

- (NSArray*)sectionIndexTitlesForTableView:(UITableView*)tableView {
	if (tableView == self.searchController.searchResultsTableView) {
		return @[];
	} else {
		return self.groups;
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView{
	if (tableView == self.searchController.searchResultsTableView) {
		return 1;
	} else {
		return self.groups.count;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (tableView == self.searchController.searchResultsTableView) {
		return self.searchResults.count;
	} else {
		NSString *key = self.groups[section];
		NSArray *group = self.groupedPasswords[key];
		NSUInteger additionalRowForSplitterCell = ([self isLastSection:section]) ? 0 : 1;
		return group.count + additionalRowForSplitterCell;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (tableView == self.tableView && [self isSplitterRow:indexPath]) {
		//load cell:
		static NSString *CellIdentifier = @"ItemListSplitterCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UIView *footerView = [[TPWSectionFooterView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(cell.bounds), kTPWSectionFooterViewHeight)];
			[cell.contentView addSubview:footerView];
		}
		return cell;
	} else {
		//load cell:
		static NSString *CellIdentifier = @"ItemListItemCell";
		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[TPWPlainTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		}
		
		//load corresponding password:
		TPW1PasswordItem *pw;
		if (tableView == self.searchController.searchResultsTableView) {
			pw = self.searchResults[indexPath.row];
		} else {
			NSString *key = self.groups[indexPath.section];
			NSArray *group = self.groupedPasswords[key];
			pw = group[indexPath.row];
		}
		
		//configure cell:
		cell.textLabel.text = pw.title;
		cell.imageView.image = pw.type.typeIcon;
		cell.imageView.highlightedImage = pw.type.highlightedTypeIcon;

		return cell;
	}
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//suppress selecting splitter rows, select prev row instead
	NSIndexPath *previousRow = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
	return (tableView == self.tableView && [self isSplitterRow:indexPath]) ? previousRow : indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//load corresponding password:
	TPW1PasswordItem *pw;
	if (tableView == self.searchController.searchResultsTableView) {
		pw = self.searchResults[indexPath.row];
		[self.searchController.searchBar resignFirstResponder];
	} else {
		NSString *key = self.groups[indexPath.section];
		NSArray *group = self.groupedPasswords[key];
		pw = group[indexPath.row];
	}
	[[self sharedTPWRootViewController] showDetailsOfItem:pw];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	if (tableView == self.searchController.searchResultsTableView) {
		return 0.0;
	} else {
		return kTPWSectionHeaderViewHeight;
	}
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	if (tableView == self.searchController.searchResultsTableView) {
		return nil;
	} else {
		NSString *sectionName = self.groups[section];
		TPWSectionHeaderView *header = [[TPWSectionHeaderView alloc] initWithText:sectionName];
		header.drawSectionSeparator = section > 0;
		return header;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (tableView == self.tableView && [self isSplitterRow:indexPath]) ? kTPWSectionFooterViewHeight : tableView.rowHeight;
}

#pragma mark - viewcontroller delegate stuff

- (void)loadView {
	self.tableView = [[TPWItemListTableView alloc] initWithFrame:self.navigationController.view.bounds style:UITableViewStylePlain];
	self.tableView.dataSource = self;
	self.tableView.delegate = self;
	self.view = self.tableView; //this is an alias anyway, but who knows, if that will change in future
}

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
