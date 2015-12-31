//
//  TPWSettingsWebDAVScreen.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.11.13.
//
//

#import "UIAlertView+TPWAlerts.h"
#import "UIColor+TPWColors.h"
#import "TPWiOSVersions.h"
#import "TPWReachability.h"
#import "TPWSettings.h"
#import "TPWProgressHUD.h"
#import "TPWPooledAsyncHttpClient.h"

#import "TPWSettingsWebDAVScreen.h"
#import "TPWWebDAVDirectoryBrowser.h"
#import "TPWGroupedTableViewCell.h"
#import "TPWTextFieldTableViewCell.h"

typedef NS_ENUM(NSUInteger, TPWSettingsWebDAVRow) {
	TPWSettingsWebDAVRowUrl,
	TPWSettingsWebDAVRowUser,
	TPWSettingsWebDAVRowPass,
	TPWSettingsWebDAVRowSavePass,
	TPWSettingsWebDAVRowTrustAllSSL
};

NSUInteger const kTPWSettingsWebDAVRows = 5;

@interface TPWSettingsWebDAVScreen () <UITextFieldDelegate, TPWImportViewControllerDelegate>
@property (nonatomic, strong) TPWReachability *hostReachability;
@property (nonatomic, weak) UITextField *urlField;
@property (nonatomic, weak) UITextField *userField;
@property (nonatomic, weak) UITextField *passField;
@property (nonatomic, weak) UISwitch *shouldSavePassSwitch;
@property (nonatomic, weak) UISwitch *shouldTrustAllSSLSwitch;
@property (nonatomic, strong) TPWPooledAsyncHttpClient *httpClient;
@property (nonatomic, assign) BOOL willShowImportViewController;
@end

@implementation TPWSettingsWebDAVScreen

- (id)initWithImportFinishedDelegate:(id<TPWImportViewControllerDelegate>)importFinishedDelegate {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.importFinishedDelegate = importFinishedDelegate;
		self.title = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.title", @"navigation bar title of setting webdav screen");
		
		// Continue button on the right.
		NSString *continueButtonTitle = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.continue", @"continue");
		UIBarButtonItem *continueButton;
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			continueButton = [[UIBarButtonItem alloc] initWithTitle:continueButtonTitle style:UIBarButtonItemStyleDone target:self action:@selector(continueButtonPressed:)];
		} else {
			continueButton = [TPWBarButtonItem tpwBarButtonWithTitle:continueButtonTitle target:self action:@selector(continueButtonPressed:)];
		}
		self.navigationItem.rightBarButtonItem = continueButton;
		
		self.httpClient = [[TPWPooledAsyncHttpClient alloc] init];
	}
	return self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self toggleContinueButtonEnabled];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	[self resetAllStoredCredentials];
	[self saveChanges];
	self.hostReachability = nil;
	[self.httpClient cancelAllRequest];
	if (!self.willShowImportViewController) {
		[TPWProgressHUD dismiss];
	}
}

- (void)resetAllStoredCredentials {
	NSURLCredentialStorage *store = [NSURLCredentialStorage sharedCredentialStorage];
	for (NSURLProtectionSpace *protectionSpace in [store allCredentials]) {
		NSDictionary *userToCredentialMap = [[NSURLCredentialStorage sharedCredentialStorage] credentialsForProtectionSpace:protectionSpace];
		for (NSString *user in userToCredentialMap) {
			NSURLCredential *credential = [userToCredentialMap objectForKey:user];
			[store removeCredential:credential forProtectionSpace:protectionSpace];
		}
	}
}

- (void)saveChanges {
	[TPWSettings setWebDAVUrl:self.urlField.text];
	[TPWSettings setWebDAVUser:self.userField.text];
	
	BOOL shouldSavePass = self.shouldSavePassSwitch.on;
	[TPWSettings setWebDAVShouldSavePass:shouldSavePass];
	if (shouldSavePass) {
		[TPWSettings setWebDAVPass:self.passField.text];
	} else {
		[TPWSettings setWebDAVPass:nil];
	}
	
	[TPWSettings setWebDAVShouldTrustAllSSL:self.shouldTrustAllSSLSwitch.on];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kTPWSettingsWebDAVRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.row == TPWSettingsWebDAVRowSavePass || indexPath.row == TPWSettingsWebDAVRowTrustAllSSL) {
		static NSString *CellIdentifier = @"TPWSwitchCell";
		TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
			aSwitch.onTintColor = [UIColor tpwOrangeColor];
			cell.accessoryView = aSwitch;
		}
		[self configureSwitchCell:cell atIndexPath:indexPath];
		return cell;
	} else {
		static NSString *CellIdentifier = @"TPWTextFieldCell";
		TPWTextFieldTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[TPWTextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		}
		[self configureTextFieldCell:cell atIndexPath:indexPath];
		return cell;
	}
}

- (void)configureSwitchCell:(TPWGroupedTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case TPWSettingsWebDAVRowSavePass:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			self.shouldSavePassSwitch = (UISwitch *)cell.accessoryView;
			self.shouldSavePassSwitch.on = [TPWSettings webDAVShouldSavePass];
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.savePass", @"webdav save credentials");
			break;
		case TPWSettingsWebDAVRowTrustAllSSL:
			cell.position = TPWCellBackgroundViewPositionBottom;
			self.shouldTrustAllSSLSwitch = (UISwitch *)cell.accessoryView;
			self.shouldTrustAllSSLSwitch.on = [TPWSettings webDAVShouldTrustAllSSL];
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.trustAllSSL", @"webdav trust all ssl");
			break;
		default:
			break;
	}
}

- (void)configureTextFieldCell:(TPWTextFieldTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	switch (indexPath.row) {
		case TPWSettingsWebDAVRowUrl:
			cell.position = TPWCellBackgroundViewPositionTop;
			self.urlField = cell.textField;
			self.urlField.delegate = self;
			self.urlField.text = [TPWSettings webDAVUrl];
			self.urlField.placeholder = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.url", @"webdav url");
			self.urlField.keyboardType = UIKeyboardTypeURL;
			self.urlField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			self.urlField.autocorrectionType = UITextAutocorrectionTypeNo;
			break;
		case TPWSettingsWebDAVRowUser:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			self.userField = cell.textField;
			self.userField.delegate = self;
			self.userField.text = [TPWSettings webDAVUser];
			self.userField.placeholder = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.user", @"webdav user");
			self.userField.autocapitalizationType = UITextAutocapitalizationTypeNone;
			self.userField.autocorrectionType = UITextAutocorrectionTypeNo;
			break;
		case TPWSettingsWebDAVRowPass:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			self.passField = cell.textField;
			self.passField.delegate = self;
			self.passField.text = [TPWSettings webDAVPass];
			self.passField.placeholder = NSLocalizedString(@"ui.modalDialogs.settingsWebDAVScreen.pass", @"webdav pass");
			self.passField.secureTextEntry = YES;
			break;
		default:
			break;
	}
}

#pragma mark - UI events

- (void)textFieldDidEndEditing:(UITextField *)textField {
	if (textField == self.urlField) {
		if (![self.urlField.text hasPrefix:@"http://"] && ![self.urlField.text hasPrefix:@"https://"]) {
			self.urlField.text = [@"http://" stringByAppendingString:self.urlField.text];
		}
		[self toggleContinueButtonEnabled];
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	if (textField == self.urlField) {
		[self.userField becomeFirstResponder];
	} else if (textField == self.userField) {
		[self.passField becomeFirstResponder];
	} else {
		[textField resignFirstResponder];
	}
	return YES;
}

- (void)toggleContinueButtonEnabled {
	NSURL *url = [NSURL URLWithString:self.urlField.text];
	if (url.host != nil) {
		self.navigationItem.rightBarButtonItem.enabled = [TPWReachability hostIsReachable:url.host];
		self.hostReachability = [[TPWReachability alloc] initWithHostname:url.host onChange:^(Reachability *reachability) {
			BOOL reachable = reachability.currentReachabilityStatus != NotReachable;
			self.navigationItem.rightBarButtonItem.enabled = reachable;
		}];
	} else {
		self.navigationItem.rightBarButtonItem.enabled = NO;
		self.hostReachability = nil;
	}
}

- (void)continueButtonPressed:(id)sender {
	[TPWProgressHUD show];
	self.navigationItem.rightBarButtonItem.enabled = NO;
	[self.tableView endEditing:YES];
	
	[self saveChanges];
	[self resetAllStoredCredentials];
	NSURL *url = [NSURL URLWithString:self.urlField.text];
	self.httpClient.username = self.userField.text;
	self.httpClient.password = self.passField.text;
	
	if ([TPWReachability hostIsReachable:url.host]) {
		[self checkWebDAVCompatibilityWithURL:url];
	}
}

- (void)checkWebDAVCompatibilityWithURL:(NSURL *)url {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"OPTIONS";
	
	__weak TPWSettingsWebDAVScreen *weakSelf = self;
	[self.httpClient makeRequest:request downloadToPath:nil onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		if (error) {
			[weakSelf.httpClient cancelRequest:tag];
			[TPWProgressHUD dismiss];
			
			UIAlertView *alertView = [UIAlertView tpwAlertWithError:error];
			[alertView show];
			[weakSelf toggleContinueButtonEnabled];
		} else {
			if ([response isSupportingWebDAVProtocol]) {
				[weakSelf checkWebDAVCredentialsWithURL:url];
			} else {
				[TPWProgressHUD dismiss];
				
				NSDictionary *userInfo = @{NSLocalizedDescriptionKey: NSLocalizedString(@"error.http.unsupportedProtocol", @"TPWPooledAsyncHttpClientErrorUnsupportedProtocol")};
				NSError *myError = [[NSError alloc] initWithDomain:kTPWPooledAsyncHttpClientErrorDomain code:TPWPooledAsyncHttpClientErrorUnsupportedProtocol userInfo:userInfo];
				UIAlertView *alertView = [UIAlertView tpwAlertWithError:myError];
				[alertView show];
				[weakSelf toggleContinueButtonEnabled];
			}
		}
	} onProgress:nil];
}

- (void)checkWebDAVCredentialsWithURL:(NSURL *)url {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
	request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
	request.HTTPMethod = @"PROPFIND";
	[request addValue:@"1" forHTTPHeaderField:@"Depth"];
	
	__weak TPWSettingsWebDAVScreen *weakSelf = self;
	[self.httpClient makeRequest:request downloadToPath:nil onRedirect:nil onCompletion:^(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error) {
		if (error) {
			[weakSelf.httpClient cancelRequest:tag];
			[TPWProgressHUD dismiss];
			
			UIAlertView *alertView = [UIAlertView tpwAlertWithError:error];
			[alertView show];
			[weakSelf toggleContinueButtonEnabled];
		} else {
			[weakSelf showImportViewControllerWithURL:url];
		}
	} onProgress:nil];
}

- (void)showImportViewControllerWithURL:(NSURL *)url {
	self.willShowImportViewController = YES;
	TPWWebDAVDirectoryBrowser *directoryBrowser = [[TPWWebDAVDirectoryBrowser alloc] initWithWorkingDirectory:self.urlField.text username:self.userField.text password:self.passField.text];
	TPWImportViewController *importViewController = [[TPWImportViewController alloc] initWithDirectoryBrowser:directoryBrowser directoryName:url.path];
	importViewController.delegate = self;
	[self.navigationController pushViewController:importViewController animated:YES];
}

#pragma mark -
#pragma mark TPWImportViewControllerDelegate

- (void)importViewControllerFinishedSuccessfully:(TPWImportViewController*)importViewController {
	[self.importFinishedDelegate importViewControllerFinishedSuccessfully:importViewController];
}

- (void)importViewController:(TPWImportViewController*)importViewController failedWithError:(NSError*)error {
	[self.navigationController popToViewController:self animated:YES];
}

@end
