//
//  TPWWelcomeScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/12/13.
//
//

#import <DropboxSDK/DropboxSDK.h>
#import "UIViewController+TPWSharedRootViewController.h"
#import "UIAlertView+TPWAlerts.h"
#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPWDecryptor.h"
#import "TPW1PasswordRepository.h"
#import "TPWReachability.h"
#import "TPWiOSVersions.h"

#import "TPWWelcomeScreen.h"
#import "TPWHtmlScreen.h"
#import "TPWUnlockScreen.h"
#import "TPWImportViewController.h"
#import "TPWDropboxDirectoryBrowser.h"
#import "TPWiTunesDirectoryBrowser.h"
#import "TPWSettingsWebDAVScreen.h"

CGFloat const kTPWWelcomeScreenButtonWidthMax = 280.0;
CGFloat const kTPWWelcomeScreenButtonHeight = 44.0;
CGFloat const kTPWWelcomeScreenButtonLeftRightMargins = 20.0;
CGFloat const kTPWWelcomeScreenButtonTopBottomMargins = 8.0;
CGFloat const kTPWWelcomeScreenButtonImageSize = 44.0;

@interface TPWWelcomeScreen () <TPWImportViewControllerDelegate>
@end

@implementation TPWWelcomeScreen

- (id)init {
	if (self = [super initWithUniversalNibName:@"TPWWelcomeScreen"]) {
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(dropboxLinkSuccessful:)
													 name:kTPWNotificationDropboxLinkSuccessful
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	NSString *titleImageName = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? @"NavigationbarTitle-noshadow" : @"NavigationbarTitle";
	self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:titleImageName]];
	
	self.iconImageView.image = [UIImage imageNamed:@"WelcomeIcon"];
	
	NSString *importFromDropboxTitle = NSLocalizedString(@"ui.modalDialogs.welcomeScreen.importFromDropbox", @"import from dropbox text label of welcome screen");
	[self.importFromDropboxButton setTitle:importFromDropboxTitle forState:UIControlStateNormal];
	[self.importFromDropboxButton setTitle:importFromDropboxTitle forState:UIControlStateHighlighted];
	[self.importFromDropboxButton setImage:[UIImage imageNamed:@"IconDropbox"] forState:UIControlStateNormal];
	[self.importFromDropboxButton setImage:[UIImage imageNamed:@"IconDropbox_highlighted"] forState:UIControlStateHighlighted];
	
	NSString *importFromiTunesTitle = NSLocalizedString(@"ui.modalDialogs.welcomeScreen.importFromiTunes", @"import from itunes text label of welcome screen");
	[self.importFromiTunesButton setTitle:importFromiTunesTitle forState:UIControlStateNormal];
	[self.importFromiTunesButton setTitle:importFromiTunesTitle forState:UIControlStateHighlighted];
	[self.importFromiTunesButton setImage:[UIImage imageNamed:@"IconiTunes"] forState:UIControlStateNormal];
	[self.importFromiTunesButton setImage:[UIImage imageNamed:@"IconiTunes_highlighted"] forState:UIControlStateHighlighted];
	
	NSString *importFromWebDAVTitle = NSLocalizedString(@"ui.modalDialogs.welcomeScreen.importFromWebDAV", @"import from webdav text label of welcome screen");
	[self.importFromWebDAVButton setTitle:importFromWebDAVTitle forState:UIControlStateNormal];
	[self.importFromWebDAVButton setTitle:importFromWebDAVTitle forState:UIControlStateHighlighted];
	[self.importFromWebDAVButton setImage:[UIImage imageNamed:@"IconWebDAV"] forState:UIControlStateNormal];
	[self.importFromWebDAVButton setImage:[UIImage imageNamed:@"IconWebDAV_highlighted"] forState:UIControlStateHighlighted];
	
	NSString *helpTitle = NSLocalizedString(@"ui.modalDialogs.welcomeScreen.help", @"help text label of welcome screen");
	[self.helpButton setTitle:helpTitle forState:UIControlStateNormal];
	[self.helpButton setTitle:helpTitle forState:UIControlStateHighlighted];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	//when this screen is shown, make sure, all previously shown data is wiped
	[[TPWDecryptor sharedInstance] wipeMasterKeys];
	[[TPW1PasswordRepository sharedInstance] wipeData];
	BOOL animateWipe = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) ? animated : NO;
	[self.sharedTPWRootViewController wipeScreenAnimated:animateWipe];
	//layout
	[self layoutViews];
}

- (void)layoutViews {
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
		[self layoutViewsLandscape];
	} else {
		[self layoutViewsPortrait];
	}
}

- (void)layoutViewsPortrait {
	CGPoint center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
	
	CGSize importFromDropboxTitleSize = [self.importFromDropboxButton.titleLabel.text sizeWithFont:self.importFromDropboxButton.titleLabel.font];
	CGSize importFromiTunesTitleSize = [self.importFromiTunesButton.titleLabel.text sizeWithFont:self.importFromiTunesButton.titleLabel.font];
	CGSize importFromWebDAVTitleSize = [self.importFromWebDAVButton.titleLabel.text sizeWithFont:self.importFromWebDAVButton.titleLabel.font];
	CGFloat buttonWidth = MIN(kTPWWelcomeScreenButtonWidthMax, MAX(MAX(importFromDropboxTitleSize.width, importFromiTunesTitleSize.width), importFromWebDAVTitleSize.width) + kTPWWelcomeScreenButtonLeftRightMargins + kTPWWelcomeScreenButtonImageSize);
	if ((NSInteger)buttonWidth % 2 == 1) {
		buttonWidth += 1.0;
	}
	CGFloat buttonOriginX = center.x - buttonWidth / 2.0;
	
	CGRect importFromDropboxRect = self.importFromDropboxButton.frame;
	importFromDropboxRect.origin.x = buttonOriginX;
	importFromDropboxRect.origin.y = center.y - CGRectGetHeight(importFromDropboxRect) - kTPWWelcomeScreenButtonTopBottomMargins;
	importFromDropboxRect.size.width = buttonWidth;
	self.importFromDropboxButton.frame = importFromDropboxRect;
	
	CGRect importFromiTunesRect = self.importFromiTunesButton.frame;
	importFromiTunesRect.origin.x = buttonOriginX;
	importFromiTunesRect.origin.y = center.y;
	importFromiTunesRect.size.width = buttonWidth;
	self.importFromiTunesButton.frame = importFromiTunesRect;
	
	CGRect importFromWebDAVRect = self.importFromWebDAVButton.frame;
	importFromWebDAVRect.origin.x = buttonOriginX;
	importFromWebDAVRect.origin.y = center.y + CGRectGetHeight(importFromWebDAVRect) + kTPWWelcomeScreenButtonTopBottomMargins;
	importFromWebDAVRect.size.width = buttonWidth;
	self.importFromWebDAVButton.frame = importFromWebDAVRect;
	
	CGRect helpRect = self.helpButton.frame;
	helpRect.origin.x = buttonOriginX;
	helpRect.origin.y = CGRectGetMaxY(importFromWebDAVRect) + kTPWWelcomeScreenButtonTopBottomMargins * 4.0;
	helpRect.size.width = buttonWidth;
	self.helpButton.frame = helpRect;
	
	CGRect iconRect = self.iconImageView.frame;
	iconRect.origin.x = center.x - CGRectGetWidth(iconRect) / 2.0;
	iconRect.origin.y = floorf((CGRectGetMinY(importFromDropboxRect) - CGRectGetHeight(iconRect)) / 2.0);
	self.iconImageView.frame = iconRect;
}

- (void)layoutViewsLandscape {
	// right side
	CGPoint rightCenter = CGPointMake(CGRectGetWidth(self.view.bounds) - (kTPWWelcomeScreenButtonWidthMax + kTPWWelcomeScreenButtonLeftRightMargins) / 2.0, CGRectGetMidY(self.view.bounds));
	CGSize importFromDropboxTitleSize = [self.importFromDropboxButton.titleLabel.text sizeWithFont:self.importFromDropboxButton.titleLabel.font];
	CGSize importFromiTunesTitleSize = [self.importFromiTunesButton.titleLabel.text sizeWithFont:self.importFromiTunesButton.titleLabel.font];
	CGSize importFromWebDAVTitleSize = [self.importFromWebDAVButton.titleLabel.text sizeWithFont:self.importFromWebDAVButton.titleLabel.font];
	CGFloat buttonWidth = MIN(kTPWWelcomeScreenButtonWidthMax, MAX(MAX(importFromDropboxTitleSize.width, importFromiTunesTitleSize.width), importFromWebDAVTitleSize.width) + kTPWWelcomeScreenButtonLeftRightMargins + kTPWWelcomeScreenButtonImageSize);
	if ((NSInteger)buttonWidth % 2 == 1) {
		buttonWidth += 1.0;
	}
	CGFloat buttonOriginX = rightCenter.x - buttonWidth / 2.0;
	
	CGFloat totalButtonsHeight = kTPWWelcomeScreenButtonHeight * 4.0 + kTPWWelcomeScreenButtonTopBottomMargins * 6.0;
	CGFloat currentButtonOriginY = rightCenter.y - totalButtonsHeight / 2.0;
	
	CGRect importFromDropboxRect = self.importFromDropboxButton.frame;
	importFromDropboxRect.origin.x = buttonOriginX;
	importFromDropboxRect.origin.y = currentButtonOriginY;
	importFromDropboxRect.size.width = buttonWidth;
	self.importFromDropboxButton.frame = importFromDropboxRect;
	currentButtonOriginY += kTPWWelcomeScreenButtonHeight + kTPWWelcomeScreenButtonTopBottomMargins;
	
	CGRect importFromiTunesRect = self.importFromiTunesButton.frame;
	importFromiTunesRect.origin.x = buttonOriginX;
	importFromiTunesRect.origin.y = currentButtonOriginY;
	importFromiTunesRect.size.width = buttonWidth;
	self.importFromiTunesButton.frame = importFromiTunesRect;
	currentButtonOriginY += kTPWWelcomeScreenButtonHeight + kTPWWelcomeScreenButtonTopBottomMargins;
	
	CGRect importFromWebDAVRect = self.importFromWebDAVButton.frame;
	importFromWebDAVRect.origin.x = buttonOriginX;
	importFromWebDAVRect.origin.y = currentButtonOriginY;
	importFromWebDAVRect.size.width = buttonWidth;
	self.importFromWebDAVButton.frame = importFromWebDAVRect;
	currentButtonOriginY += kTPWWelcomeScreenButtonHeight + kTPWWelcomeScreenButtonTopBottomMargins * 4.0;
	
	CGRect helpRect = self.helpButton.frame;
	helpRect.origin.x = buttonOriginX;
	helpRect.origin.y = currentButtonOriginY;
	helpRect.size.width = buttonWidth;
	self.helpButton.frame = helpRect;
	
	// left side
	CGPoint leftCenter = CGPointMake(floorf(buttonOriginX / 2.0), CGRectGetMidY(self.view.bounds));
	self.iconImageView.center = leftCenter;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	[self layoutViews];
}

#pragma mark -
#pragma mark Action Handlers

- (IBAction)presentDropboxImporter:(id)sender {
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

- (IBAction)presentiTunesImporter:(id)sender {
	TPWiTunesDirectoryBrowser *directoryBrowser = [[TPWiTunesDirectoryBrowser alloc] initWithWorkingDirectory:[TPWFileUtil documentsPath]];
	TPWImportViewController *importViewController = [[TPWImportViewController alloc] initWithDirectoryBrowser:directoryBrowser];
	importViewController.delegate = self;
	[self.navigationController pushViewController:importViewController animated:YES];
}

- (IBAction)presentWebDAVImporter:(id)sender {
	TPWSettingsWebDAVScreen *webDAVScreen = [[TPWSettingsWebDAVScreen alloc] initWithImportFinishedDelegate:self];
	[self.navigationController pushViewController:webDAVScreen animated:YES];
}

- (IBAction)presentHelpScreen:(id)sender {
	NSString *title = NSLocalizedString(@"ui.modalDialogs.helpScreen.title", @"navigation bar title of help screen");
	TPWHtmlScreen *infoScreen = [[TPWHtmlScreen alloc] initWithTitle:title htmlPathName:@"help"];
	[self.navigationController pushViewController:infoScreen animated:YES];
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

#pragma mark -
#pragma mark TPWImportViewControllerDelegate

- (void)importViewControllerFinishedSuccessfully:(TPWImportViewController*)importViewController {
	[self presentUnlockDialog];
}

- (void)importViewController:(TPWImportViewController*)importViewController failedWithError:(NSError*)error {
	[self.navigationController popToViewController:self animated:YES];
}

#pragma mark -
#pragma mark Notifications

- (void)dropboxLinkSuccessful:(NSNotification *)notification {
	NSAssert([[notification name] isEqualToString:kTPWNotificationDropboxLinkSuccessful], @"dropLinkSuccessful is called from wrong notification.");
	
	[self presentDropboxImporter:self];
}

@end
