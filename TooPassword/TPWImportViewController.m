//
//  TPWImportViewController.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWProgressHUD.h"
#import "UIScrollView+SVPullToRefresh.h"

#import "TPWConstants.h"
#import "TPWiOSVersions.h"
#import "TPWGroupedTableViewCell.h"

#import "TPWImportViewController.h"

@interface TPWImportViewController ()
@property (nonatomic, strong) TPWAbstractDirectoryBrowser *directoryBrowser;
@property (nonatomic, strong) TPWAbstractImporter *keychainImporter;
@property (nonatomic, strong) NSDictionary *directoryContents;
@property (nonatomic, strong) NSArray *sortedDirectoryContentKeys;
@property (nonatomic, assign) BOOL containsImportableItem;
@property (atomic, assign) BOOL showsHUD;
@end

@implementation TPWImportViewController

- (id)initWithDirectoryBrowser:(TPWAbstractDirectoryBrowser *)directoryBrowser {
	return [self initWithDirectoryBrowser:directoryBrowser directoryName:[directoryBrowser.path lastPathComponent]];
}

- (id)initWithDirectoryBrowser:(TPWAbstractDirectoryBrowser *)directoryBrowser directoryName:(NSString*)directoryName {
	NSParameterAssert(directoryBrowser);
	NSParameterAssert(directoryName);
	
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.directoryBrowser = directoryBrowser;
		
		// Set title to directory name, if it's not root.
		self.title = [self.directoryBrowser.relativeWorkingDirectoryForDisplay isEqualToString:kTPWRootDirectory]
					? NSLocalizedString(@"keychainSync.keychainImportController.title", @"navigation bar title of keychain import")
					: directoryName;
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	// Pull to refresh.
	__weak TPWImportViewController *weakSelf = self;
	[self.tableView addPullToRefreshWithActionHandler:^{
		[weakSelf loadDirectoryContents];
	}];
	
	// Right bar button
	NSString *rightBarButtonTitle = [self.directoryBrowser secondaryActionButtonTitle];
	if (rightBarButtonTitle) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:rightBarButtonTitle style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemTapped:)];
	}
	
	// Loading directory contents.
	if (![self.directoryBrowser contentsOfDirectoryWillLoadImmediately]) {
		[self showHUD];
	}
	[self loadDirectoryContents];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	self.navigationItem.rightBarButtonItem = nil;
	
	[self.directoryBrowser cancel];
	[self.keychainImporter cancel];
	[self dismissHUD];
}

- (void)rightBarButtonItemTapped:(id)sender {
	NSError *error = nil;
	if (![self.directoryBrowser performSecondaryActionAndContinueBrowsingIfWithoutError:&error]) {
		[self.delegate importViewController:self failedWithError:error];
	}
}

- (void)loadDirectoryContents {
	__weak TPWImportViewController *weakSelf = self;
	
	[self.directoryBrowser contentsOfDirectory:^(NSDictionary *contents, NSError *error) {
		if (error) {
			[weakSelf showHUDWithErrorStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusError", @"progress hud error status")];
		} else {
			weakSelf.directoryContents = contents;
			weakSelf.sortedDirectoryContentKeys = [contents.allKeys sortedArrayUsingComparator:^NSComparisonResult(id path1, id path2) {
				NSString *filename1 = contents[path1];
				NSString *filename2 = contents[path2];
				return [filename1 compare:filename2 options:NSCaseInsensitiveSearch|NSNumericSearch];
			}];
			[weakSelf checkForImportableItems:contents.allKeys];
			[weakSelf.tableView reloadData];
			[weakSelf dismissHUD];
		}
		
		[weakSelf.tableView.pullToRefreshView stopAnimating];
	}];
}

- (void)checkForImportableItems:(NSArray*)filePaths {
	self.containsImportableItem = NO;
	
	for (NSString *filePath in filePaths) {
		if ([self.directoryBrowser canImportFileAtPath:filePath]) {
			self.containsImportableItem = YES;
			break;
		}
	}
}

- (void)showHUD {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (!self.showsHUD) {
			[TPWProgressHUD show];
			self.showsHUD = YES;
		}
	});
}

- (void)showHUDWithErrorStatus:(NSString *)errorStatus {
	dispatch_async(dispatch_get_main_queue(), ^{
		[TPWProgressHUD showErrorWithStatus:errorStatus];
		self.showsHUD = NO;
	});
}

- (void)dismissHUD {
	dispatch_async(dispatch_get_main_queue(), ^{
		if (self.showsHUD) {
			[TPWProgressHUD dismiss];
			self.showsHUD = NO;
		}
	});
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.directoryContents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if (cell == nil) {
		cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (void)configureCell:(TPWGroupedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSString *filePath = self.sortedDirectoryContentKeys[indexPath.row];
	
	if ([self.directoryContents count] == 1) {
		cell.position = TPWCellBackgroundViewPositionSingle;
	} else if (indexPath.row == 0) {
		cell.position = TPWCellBackgroundViewPositionTop;
	} else if (indexPath.row == [self.directoryContents count] - 1) {
		cell.position = TPWCellBackgroundViewPositionBottom;
	} else {
		cell.position = TPWCellBackgroundViewPositionMiddle;
	}
	
	cell.textLabel.text = self.directoryContents[filePath];
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	
	if ([self.directoryBrowser canImportFileAtPath:filePath]) {
		UIImage *keychainImageActive = [UIImage imageNamed:@"IconPasswords"];
		UIImage *keychainImageHighlighted = [UIImage imageNamed:@"IconPasswords_highlighted"];
		cell.imageView.image = keychainImageActive;
		cell.imageView.highlightedImage = keychainImageHighlighted;
		cell.accessoryType = UITableViewCellAccessoryNone;
	} else {
		UIImage *directoryImageActive = [UIImage imageNamed:@"IconDirectory"];
		UIImage *directoryImageHighlighted = [UIImage imageNamed:@"IconDirectory_highlighted"];
		cell.imageView.image = directoryImageActive;
		cell.imageView.highlightedImage = directoryImageHighlighted;
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSString *relativeWorkingDirectoryForDisplay = [self.directoryBrowser relativeWorkingDirectoryForDisplay];
	return [relativeWorkingDirectoryForDisplay isEqualToString:kTPWRootDirectory] ? nil : relativeWorkingDirectoryForDisplay;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *footer = nil;
	
	if (self.directoryContents && !self.containsImportableItem) {
		footer = NSLocalizedString(@"keychainSync.keychainImportController.footerNoKeychainInFolder", @"no keychain in this folder");
	}
	
	return footer;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *filePath = self.sortedDirectoryContentKeys[indexPath.row];
	
	if ([self.directoryBrowser canImportFileAtPath:filePath]) {
		[self importKeychainAtPath:filePath];
	} else {
		[self openDirectoryAtPath:filePath];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)importKeychainAtPath:(NSString *)path {
	self.showsHUD = YES;
	[TPWProgressHUD showWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusLoading", @"progress hud loading status")];
	self.tableView.userInteractionEnabled = NO;
	
	self.keychainImporter = [self.directoryBrowser importerForKeychainAtPath:path];
	[self.keychainImporter importKeychainAtPath:path onCompletion:^(BOOL success, NSError *error) {
		self.showsHUD = NO;
		if (success) {
			[TPWProgressHUD showSuccessWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusSuccess", @"progress hud success status")];
			[self.delegate importViewControllerFinishedSuccessfully:self];
		} else {
			[TPWProgressHUD showErrorWithStatus:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusError", @"progress hud error status")];
			[self.delegate importViewController:self failedWithError:error];
		}
		self.tableView.userInteractionEnabled = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
	} onProgress:^(CGFloat progress) {
		[TPWProgressHUD showProgress:progress status:NSLocalizedString(@"keychainSync.keychainImportController.progressHudStatusLoading", @"progress hud loading status")];
	}];
}

- (void)openDirectoryAtPath:(NSString *)path {
	NSString *filename = self.directoryContents[path];
	TPWAbstractDirectoryBrowser *subdirectoryBrowser = [self.directoryBrowser browserForWorkingDirectory:path];
	TPWImportViewController *importViewController = [[TPWImportViewController alloc] initWithDirectoryBrowser:subdirectoryBrowser directoryName:filename];
	importViewController.delegate = self.delegate;
	[self.navigationController pushViewController:importViewController animated:YES];
}

@end
