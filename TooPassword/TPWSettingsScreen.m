//
//  TPWSettingsScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/18/13.
//
//

#import <DropboxSDK/DropboxSDK.h>
#import "SORelativeDateTransformer.h"
#import "UIViewController+TPWSharedRootViewController.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "UIAlertView+TPWAlerts.h"
#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPWSettings.h"
#import "TPWDecryptor.h"
#import "TPW1PasswordRepository.h"
#import "TPWReachability.h"
#import "TPWGroupedTableViewCell.h"
#import "UIAlertView+TPWAlerts.h"
#import "TPWSettingsScreen.h"
#import "TPWSettingsWebDAVScreen.h"
#import "TPWSettingsSearchScreen.h"
#import "TPWSettingsAutoLockScreen.h"
#import "TPWSettingsClearClipboardScreen.h"
#import "TPWWelcomeScreen.h"
#import "TPWUnlockScreen.h"
#import "TPWHtmlScreen.h"
#import "TPWImportViewController.h"
#import "TPWDropboxDirectoryBrowser.h"
#import "TPWiTunesDirectoryBrowser.h"
#import "TPWMetadataReader.h"

NSString *const kTPWDefaultCellIdentifier = @"DefaultCell";
NSString *const kTPWValue1CellIdentifier = @"Value1Cell";

NSInteger const kTPWSettingsNumberOfSections = 6;
NSInteger const kTPWSettingsSectionGeneralNumberOfRows = 1;
NSInteger const kTPWSettingsSectionSecurityNumberOfRows = 4;
NSInteger const kTPWSettingsSectionSyncNumberOfRows = 3;
NSInteger const kTPWSettingsSectionDataNumberOfRows = 1;
NSInteger const kTPWSettingsSectionHelpNumberOfRows = 2;
NSInteger const kTPWSettingsSectionSupportNumberOfRows = 2;

NSString *const kTPWSettingsSupportSiteUrl = @"http://toopassword.com/faq/";
NSString *const kTPWSettingsFeedbackEmailAddress = @"support@toopassword.com";

typedef enum {
	TPWSettingsCellGeneralSearch,
	TPWSettingsCellSecurityAutoLock,
	TPWSettingsCellSecurityClearClipboard,
	TPWSettingsCellSecurityConcealPasswords,
	TPWSettingsCellSecurityLockNow,
	TPWSettingsCellSyncImportFromDropbox,
	TPWSettingsCellSyncImportFromiTunes,
	TPWSettingsCellSyncImportFromWebDAV,
	TPWSettingsCellDataEraseData,
	TPWSettingsCellHelpManual,
	TPWSettingsCellHelpInformation,
	TPWSettingsCellSupportSupportSite,
	TPWSettingsCellSupportSendFeedback
} TPWSettingsCell;

typedef enum {
	TPWSettingsSectionGeneral,
	TPWSettingsSectionSecurity,
	TPWSettingsSectionSync,
	TPWSettingsSectionData,
	TPWSettingsSectionHelp,
	TPWSettingsSectionSupport
} TPWSettingsSection;

typedef enum {
	TPWSettingsGeneralSectionRowSearch
} TPWSettingsGeneralSection;

typedef enum {
	TPWSettingsSecuritySectionRowAutoLock,
	TPWSettingsSecuritySectionRowClearClipboard,
	TPWSettingsSecuritySectionRowConcealPasswords,
	TPWSettingsSecuritySectionRowLockNow
} TPWSettingsSecuritySection;

typedef enum {
	TPWSettingsSyncSectionRowImportFromDropbox,
	TPWSettingsSyncSectionRowImportFromiTunes,
	TPWSettingsSyncSectionRowImportFromWebDAV
} TPWSettingsSyncSection;

typedef enum {
	TPWSettingsDataSectionRowEraseData
} TPWSettingsDataSection;

typedef enum {
	TPWSettingsHelpSectionRowManual,
	TPWSettingsHelpSectionRowInformation
} TPWSettingsHelpSection;

typedef enum {
	TPWSettingsSupportSectionRowSupportSite,
	TPWSettingsSupportSectionRowSendFeedback
} TPWSettingsSupportSection;

@interface TPWSettingsScreen () <UIActionSheetDelegate, TPWImportViewControllerDelegate>
@property (nonatomic, assign) BOOL doneButtonShown;
@property (nonatomic, strong) NSDate *importDate;
@end

@implementation TPWSettingsScreen

- (id)initWithDoneButtonShown:(BOOL)doneButtonShown {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.doneButtonShown = doneButtonShown;
		self.title = NSLocalizedString(@"ui.modalDialogs.settingsScreen.title", @"navigation bar title of setting screen");
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dropboxLinkSuccessful:)
													 name:kTPWNotificationDropboxLinkSuccessful
												   object:nil];
	}
	return self;
}

- (id)init {
	return [self initWithDoneButtonShown:YES];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	if (self.doneButtonShown) {
		// Done button on the right.
		NSString *doneButtonTitle = NSLocalizedString(@"ui.common.done", @"done");
		UIBarButtonItem *doneButton;
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			doneButton = [[UIBarButtonItem alloc] initWithTitle:doneButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(dismissSettings)];
		} else {
			doneButton = [TPWBarButtonItem tpwBarButtonWithTitle:doneButtonTitle target:self action:@selector(dismissSettings)];
		}
		self.navigationItem.rightBarButtonItem = doneButton;
	}
	
	// Cache import date to improve performance.
	TPWMetadataReader *reader = [TPWMetadataReader reader];
	self.importDate = reader.importDate;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.tableView reloadData];
}

- (void)dismissSettings {
	
	[self dismissDialogScreenAnimated:YES];
}

- (BOOL)isRootViewController {
	return ([self.navigationController.viewControllers firstObject] == self);
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self isRootViewController] ? kTPWSettingsNumberOfSections : kTPWSettingsNumberOfSections - 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger effectiveSection = [self isRootViewController] ? section : section + 2;
	
	switch (effectiveSection) {
		case TPWSettingsSectionGeneral:
			return kTPWSettingsSectionGeneralNumberOfRows;
		case TPWSettingsSectionSecurity:
			return kTPWSettingsSectionSecurityNumberOfRows;
		case TPWSettingsSectionSync:
			return kTPWSettingsSectionSyncNumberOfRows;
		case TPWSettingsSectionData:
			return kTPWSettingsSectionDataNumberOfRows;
		case TPWSettingsSectionHelp:
			return kTPWSettingsSectionHelpNumberOfRows;
		case TPWSettingsSectionSupport:
			return kTPWSettingsSectionSupportNumberOfRows;
		default:
			return 0;
	}

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (cell == nil) {
		if ([cellIdentifier isEqualToString:kTPWDefaultCellIdentifier]) {
			cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		} else if ([cellIdentifier isEqualToString:kTPWValue1CellIdentifier]) {
			cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
		} else {
			NSAssert(false, @"Unknown cell identifier.");
		}
	}
	
	[self configureCell:cell atIndexPath:indexPath];
	
	return cell;
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [self isRootViewController] ? indexPath.section : indexPath.section + 2;
	NSInteger row = indexPath.row;
	
	NSString *cellIdentifier = kTPWDefaultCellIdentifier;
	
	if (section == TPWSettingsSectionGeneral) {
		if (row == TPWSettingsGeneralSectionRowSearch) {
			cellIdentifier = kTPWValue1CellIdentifier;
		}
	} else if (section == TPWSettingsSectionSecurity) {
		if (row == TPWSettingsSecuritySectionRowAutoLock || row == TPWSettingsSecuritySectionRowClearClipboard) {
			cellIdentifier = kTPWValue1CellIdentifier;
		}
	}
	
	return cellIdentifier;
}

- (void)configureCell:(TPWGroupedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSInteger section = [self isRootViewController] ? indexPath.section : indexPath.section + 2;
	NSInteger row = indexPath.row;
	
	cell.selectionStyle = UITableViewCellSelectionStyleGray;
	cell.imageView.image = nil;
	cell.imageView.highlightedImage = nil;
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryView = nil;
	cell.textLabel.textAlignment = NSTextAlignmentLeft;
	
	if (section == TPWSettingsSectionGeneral) {
		switch (row) {
			case TPWSettingsGeneralSectionRowSearch:
				cell.tag = TPWSettingsCellGeneralSearch;
				cell.position = TPWCellBackgroundViewPositionSingle;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionGeneral.search", @"search text label of settings screen");
				cell.detailTextLabel.text = [self searchText];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
				
			default:
				break;
		}
	} else if (section == TPWSettingsSectionSecurity) {
		switch (row) {
			case TPWSettingsSecuritySectionRowAutoLock:
				cell.tag = TPWSettingsCellSecurityAutoLock;
				cell.position = TPWCellBackgroundViewPositionTop;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSecurity.autoLock", @"auto lock text label of settings screen");
				cell.detailTextLabel.text = [self autoLockText];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
				
			case TPWSettingsSecuritySectionRowClearClipboard:
				cell.tag = TPWSettingsCellSecurityClearClipboard;
				cell.position = TPWCellBackgroundViewPositionMiddle;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSecurity.clearClipboard", @"clear clipboard text label of settings screen");
				cell.detailTextLabel.text = [self clearClipboardText];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
				
			case TPWSettingsSecuritySectionRowConcealPasswords: {
				cell.tag = TPWSettingsCellSecurityConcealPasswords;
				cell.position = TPWCellBackgroundViewPositionMiddle;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSecurity.concealPasswords", @"conceal passwords text label of settings screen");
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
				UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
				aSwitch.tag = TPWSettingsCellSecurityConcealPasswords;
				[aSwitch addTarget:self action:@selector(switchValueChanged:) forControlEvents:UIControlEventValueChanged];
				aSwitch.on = [TPWSettings concealPasswords];
				aSwitch.onTintColor = [UIColor tpwOrangeColor];
				cell.accessoryView = aSwitch;
				break;
			}
			case TPWSettingsSecuritySectionRowLockNow:
				cell.tag = TPWSettingsCellSecurityLockNow;
				cell.position = TPWCellBackgroundViewPositionBottom;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSecurity.lockNow", @"lock now text label of settings screen");
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				break;
				
			default:
				break;
		}
	} else if (section == TPWSettingsSectionSync) {
		switch (row) {
			case TPWSettingsSyncSectionRowImportFromDropbox: {
				cell.tag = TPWSettingsCellSyncImportFromDropbox;
				cell.position = TPWCellBackgroundViewPositionTop;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSync.importFromDropbox", @"import from dropbox text label of settings screen");
				cell.imageView.image = [UIImage imageNamed:@"IconDropbox"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"IconDropbox_highlighted"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case TPWSettingsSyncSectionRowImportFromiTunes: {
				cell.tag = TPWSettingsCellSyncImportFromiTunes;
				cell.position = TPWCellBackgroundViewPositionMiddle;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSync.importFromiTunes", @"import from itunes text label of settings screen");
				cell.imageView.image = [UIImage imageNamed:@"IconiTunes"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"IconiTunes_highlighted"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			case TPWSettingsSyncSectionRowImportFromWebDAV: {
				cell.tag = TPWSettingsCellSyncImportFromWebDAV;
				cell.position = TPWCellBackgroundViewPositionBottom;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSync.importFromWebDAV", @"import from webdav text label of settings screen");
				cell.imageView.image = [UIImage imageNamed:@"IconWebDAV"];
				cell.imageView.highlightedImage = [UIImage imageNamed:@"IconWebDAV_highlighted"];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
			}
			default:
				break;
		}
	} else if (section == TPWSettingsSectionData) {
		switch (row) {
			case TPWSettingsDataSectionRowEraseData:
				cell.tag = TPWSettingsCellDataEraseData;
				cell.position = TPWCellBackgroundViewPositionSingle;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionData.eraseData", @"erase data text label of settings screen");
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				break;
				
			default:
				break;
		}
	} else if (section == TPWSettingsSectionHelp) {
		switch (row) {
			case TPWSettingsHelpSectionRowManual:
				cell.tag = TPWSettingsCellHelpManual;
				cell.position = TPWCellBackgroundViewPositionTop;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionHelp.manual", @"manual text label of settings screen");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
				
			case TPWSettingsHelpSectionRowInformation:
				cell.tag = TPWSettingsCellHelpInformation;
				cell.position = TPWCellBackgroundViewPositionBottom;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionHelp.information", @"information text label of settings screen");
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				break;
				
			default:
				break;
		}
	} else if (section == TPWSettingsSectionSupport) {
		switch (row) {
			case TPWSettingsSupportSectionRowSupportSite:
				cell.tag = TPWSettingsCellSupportSupportSite;
				cell.position = TPWCellBackgroundViewPositionTop;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionHelp.supportSite", @"support site text label of settings screen");
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				break;
				
			case TPWSettingsSupportSectionRowSendFeedback:
				cell.tag = TPWSettingsCellSupportSendFeedback;
				cell.position = TPWCellBackgroundViewPositionBottom;
				cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionHelp.sendFeedback", @"send feedback text label of settings screen");
				cell.textLabel.textAlignment = NSTextAlignmentCenter;
				break;
				
			default:
				break;
		}
	} else {
		DLog(@"Section '%zd' is not defined.", section);
	}
}

- (NSString *)searchText {
	NSString *searchText = @"";
	BOOL simpleSearch = [TPWSettings simpleSearch];
	
	if (simpleSearch) {
		searchText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.simpleSearch", @"settingsScreen searchMode - simple");
	} else {
		searchText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.advancedSearch", @"settingsScreen searchMode - advanced");
	}
	
	return searchText;
}

- (NSString *)autoLockText {
	NSString *autoLockText = @"";
	NSTimeInterval autoLockTimeInterval = [TPWSettings autoLockTimeInterval];
	
	if (autoLockTimeInterval == kTPWSettingsAutoLockTimeIntervalInstant) {
		autoLockText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.instantAutoLock", @"settingsScreen autoLockTimeInterval - instant");
	} else if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval60) {
		autoLockText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.autoLockAfter60s", @"settingsScreen autoLockTimeInterval - 60s");
	} else if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval120) {
		autoLockText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.autoLockAfter120s", @"settingsScreen autoLockTimeInterval - 120s");
	} else if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval300) {
		autoLockText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.autoLockAfter300s", @"settingsScreen autoLockTimeInterval - 300s");
	} else if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval600) {
		autoLockText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.autoLockAfter600s", @"settingsScreen autoLockTimeInterval - 600s");
	} else {
		NSAssert(false, @"'autoLockTimeInterval == %f' doesn't exist.", autoLockTimeInterval);
	}
	
	return autoLockText;
}

- (NSString *)clearClipboardText {
	NSString *clearClipboardText = @"";
	NSTimeInterval clearClipboardTimeInterval = [TPWSettings clearClipboardTimeInterval];
	
	if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval30) {
		clearClipboardText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.clearClipboardAfter30s", @"settingsScreen clearClipboardTimeInterval - 30s");
	} else if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval60) {
		clearClipboardText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.clearClipboardAfter60s", @"settingsScreen clearClipboardTimeInterval - 60s");
	} else if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval120) {
		clearClipboardText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.clearClipboardAfter120s", @"settingsScreen clearClipboardTimeInterval - 120s");
	} else if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval300) {
		clearClipboardText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.clearClipboardAfter300s", @"settingsScreen clearClipboardTimeInterval - 300s");
	} else if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeIntervalNever) {
		clearClipboardText = NSLocalizedString(@"ui.modalDialogs.settingsScreen.clearClipboardDisabled", @"settingsScreen clearClipboardTimeInterval - Disabled");
	} else {
		NSAssert(false, @"'clearClipboardTimeInterval == %f' doesn't exist.", clearClipboardTimeInterval);
	}
	
	return clearClipboardText;
}

- (void)switchValueChanged:(id)sender {
	NSAssert([sender isKindOfClass:UISwitch.class], @"switchValueChanged: Unexpected parameter.");
	UISwitch *aSwitch = (UISwitch *)sender;
	
	switch (aSwitch.tag) {
		case TPWSettingsCellSecurityConcealPasswords:
			[TPWSettings setConcealPasswords:aSwitch.on];
			break;
			
		default:
			break;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	NSInteger effectiveSection = [self isRootViewController] ? section : section + 2;
	
	switch (effectiveSection) {
		case TPWSettingsSectionGeneral:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionGeneral.header", @"header for general section of settings screen");
			
		case TPWSettingsSectionSecurity:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSecurity.header", @"header for security section of settings screen");
			
		case TPWSettingsSectionSync:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSync.header", @"header for sync section of settings screen");
			
		case TPWSettingsSectionData:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionData.header", @"header for data section of settings screen");
			
		case TPWSettingsSectionHelp:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionHelp.header", @"header for help section of settings screen");
			
		case TPWSettingsSectionSupport:
			return NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSupport.header", @"header for support section of settings screen");
			
		default:
			return nil;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSInteger effectiveSection = [self isRootViewController] ? section : section + 2;
	
	switch (effectiveSection) {
		case TPWSettingsSectionSync: {
			NSString *footerTemplate = NSLocalizedString(@"ui.modalDialogs.settingsScreen.sectionSync.footer", @"footer for last import date label of settings screen");
			NSString *relativeDate = [[SORelativeDateTransformer registeredTransformer] transformedValue:self.importDate];
			return [NSString stringWithFormat:@"%@: %@", footerTemplate, relativeDate];
		}
		default:
			return nil;
	}
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	
	switch (cell.tag) {
		case TPWSettingsCellGeneralSearch:
			[self presentSearchDialog];
			break;
			
		case TPWSettingsCellSecurityAutoLock:
			[self presentAutoLockDialog];
			break;
			
		case TPWSettingsCellSecurityClearClipboard:
			[self presentClearClipboardDialog];
			break;
			
		case TPWSettingsCellSecurityLockNow:
			[self presentUnlockDialog];
			break;
			
		case TPWSettingsCellSyncImportFromDropbox:
			[self presentDropboxImporter];
			break;
			
		case TPWSettingsCellSyncImportFromiTunes:
			[self presentiTunesImporter];
			break;
			
		case TPWSettingsCellSyncImportFromWebDAV:
			[self presentWebDAVDialog];
			break;
			
		case TPWSettingsCellDataEraseData:
			[self eraseData:cell];
			break;
			
		case TPWSettingsCellHelpManual:
			[self presentHelpDialog];
			break;
			
		case TPWSettingsCellHelpInformation:
			[self presentInformationDialog];
			break;
			
		case TPWSettingsCellSupportSupportSite:
			[self openSupportSite];
			break;
			
		case TPWSettingsCellSupportSendFeedback:
			[self sendFeedback];
			break;
			
		default:
			break;
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)presentSearchDialog {
	TPWTableDialogScreen *dialogScreen = [[TPWSettingsSearchScreen alloc] init];
	[self.navigationController pushViewController:dialogScreen animated:YES];
}

- (void)presentAutoLockDialog {
	TPWTableDialogScreen *dialogScreen = [[TPWSettingsAutoLockScreen alloc] init];
	[self.navigationController pushViewController:dialogScreen animated:YES];
}

- (void)presentClearClipboardDialog {
	TPWTableDialogScreen *dialogScreen = [[TPWSettingsClearClipboardScreen alloc] init];
	[self.navigationController pushViewController:dialogScreen animated:YES];
}

- (void)presentUnlockDialog {
	//try "pop"
	for (UIViewController *viewController in self.navigationController.viewControllers) {
		if ([viewController isKindOfClass:TPWUnlockScreen.class]) {
			[self.navigationController popToViewController:viewController animated:YES];
			return;
		}
	}
	
	//else "push"
	TPWDialogScreen *dialogScreen = [[TPWUnlockScreen alloc] init];
	dialogScreen.navigationItem.hidesBackButton = YES;
	[self.navigationController pushViewController:dialogScreen animated:YES];
}

- (void)presentWelcomeDialog {
	//try "pop"
	for (UIViewController *viewController in self.navigationController.viewControllers) {
		if ([viewController isKindOfClass:TPWWelcomeScreen.class]) {
			[self.navigationController popToViewController:viewController animated:YES];
			return;
		}
	}
	
	//else "push"
	TPWDialogScreen *dialogScreen = [[TPWWelcomeScreen alloc] init];
	dialogScreen.navigationItem.hidesBackButton = YES;
	[self.navigationController pushViewController:dialogScreen animated:YES];
}


- (void)presentDropboxImporter {
	// Check if dropbox is reachable.
	if (![TPWReachability dropboxIsReachable]) {
		UIAlertView *alertView = [UIAlertView tpwDropboxNotReachableAlert];
		[alertView show];
		return;
	}
	
	// Check if dropbox is linked.
	if (![[DBSession sharedSession] isLinked]) {
		// Show Dropbox login.
		[[DBSession sharedSession] linkFromController:self.navigationController];
		return;
	}
	
	TPWDropboxDirectoryBrowser *directoryBrowser = [[TPWDropboxDirectoryBrowser alloc] initWithWorkingDirectory:kTPWRootDirectory];
	TPWImportViewController *importViewController = [[TPWImportViewController alloc] initWithDirectoryBrowser:directoryBrowser];
	importViewController.delegate = self;
	[self.navigationController pushViewController:importViewController animated:YES];
}

- (void)presentiTunesImporter {
	TPWiTunesDirectoryBrowser *directoryBrowser = [[TPWiTunesDirectoryBrowser alloc] initWithWorkingDirectory:[TPWFileUtil documentsPath]];
	TPWImportViewController *importViewController = [[TPWImportViewController alloc] initWithDirectoryBrowser:directoryBrowser];
	importViewController.delegate = self;
	[self.navigationController pushViewController:importViewController animated:YES];
}

- (void)presentWebDAVDialog {
	TPWTableDialogScreen *dialogScreen = [[TPWSettingsWebDAVScreen alloc] initWithImportFinishedDelegate:self];
	[self.navigationController pushViewController:dialogScreen animated:YES];
}

- (void)presentHelpDialog {
	NSString *title = NSLocalizedString(@"ui.modalDialogs.helpScreen.title", @"navigation bar title of help screen");
	TPWHtmlScreen *infoScreen = [[TPWHtmlScreen alloc] initWithTitle:title htmlPathName:@"help"];
	[self.navigationController pushViewController:infoScreen animated:YES];
}

- (void)openSupportSite {
	NSURL *url = [NSURL URLWithString:kTPWSettingsSupportSiteUrl];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)presentInformationDialog {
	NSString *titleFormat = NSLocalizedString(@"ui.modalDialogs.infoScreen.title", @"navigation bar title of info screen");
	NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
	NSString *build = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
	TPWHtmlScreen *infoScreen = [[TPWHtmlScreen alloc] initWithTitle:[NSString stringWithFormat:titleFormat, version, build] htmlPathName:@"info"];
	[self.navigationController pushViewController:infoScreen animated:YES];
}

- (void)sendFeedback {
	NSString *feedbackSubject = @"Feedback";
	NSString *feedbackBody = NSLocalizedString(@"email.feedback.body", @"send feedback email - body");
	NSString *feedbackUrl = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", kTPWSettingsFeedbackEmailAddress, feedbackSubject, feedbackBody];
	feedbackUrl = [feedbackUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:feedbackUrl]];
}

- (void)eraseData:(UIView *)senderView {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"ui.modalDialogs.settingsScreen.eraseDataConfirm", @"confirm erase data in action sheet of settings screen")
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"ui.common.cancel", @"cancel")
											   destructiveButtonTitle:NSLocalizedString(@"ui.common.yes", @"yes")
													otherButtonTitles:nil];
	[actionSheet showFromRect:senderView.frame inView:self.view animated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	switch (buttonIndex) {
		case 0:
			[TPWFileUtil eraseKeychain];
			[[TPWSettings sharedInstance] resetUserDefaults];
			[self presentWelcomeDialog];
			break;
			
		default:
			break;
	}
}

#pragma mark -
#pragma mark TPWImportViewControllerDelegate

- (void)importViewControllerFinishedSuccessfully:(TPWImportViewController*)importViewController {
	if (![[TPWDecryptor sharedInstance] hasEncryptionKeysFileChanged]) {
		[[TPW1PasswordRepository sharedInstance] loadPasswordsWithError:NULL]; //ignore errors
		[[TPW1PasswordRepository sharedInstance] decryptPasswords];
		[[self sharedTPWRootViewController] refreshItemListAnimated:YES];
		[self.navigationController popToViewController:self animated:YES];
	} else {
		[self presentUnlockDialog];
	}
}

- (void)importViewController:(TPWImportViewController*)importViewController failedWithError:(NSError*)error {
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark Notifications

- (void)dropboxLinkSuccessful:(NSNotification *)notification {
	NSAssert([[notification name] isEqualToString:kTPWNotificationDropboxLinkSuccessful], @"dropLinkSuccessful is called from wrong notification.");
	
	[self presentDropboxImporter];
}

@end
