//
//  TPW1PasswordItemPasswords.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 25.01.13.
//
//

#import "TPW1PasswordItemPasswords.h"
#import "TPWGroupedTableViewCell.h"
#import "TPWObfuscatedTableViewCell.h"
#import "UIFont+TPWFonts.h"
#import "NSString+TPWExtensions.h"

NSString *const kTPW1PasswordItemPasswordsJsonKeyPassword = @"password";

typedef enum {
	TPW1PasswordItemPasswordsCellPassword,
	TPW1PasswordItemPasswordsCellLocation
} TPW1PasswordItemPasswordsCell;

@implementation TPW1PasswordItemPasswords

#pragma mark - searching

- (BOOL)matchesSearchTerm:(NSString*)word searchTitleOnly:(BOOL)simpleSearch {
	if (simpleSearch) {
		return [super matchesSearchTerm:word searchTitleOnly:simpleSearch];
	}
	NSString *haystack = [NSString haystackUsingHay:self.title ? : @"", self.location ? : @"", self.notesPlain ? : @"", nil];
	return [haystack rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound;
}

#pragma mark - decryption

- (void)didDecrypt:(NSDictionary*)decrypted {
	[super didDecrypt:decrypted];
	self.password = decrypted[kTPW1PasswordItemPasswordsJsonKeyPassword];
}

#pragma mark - obfuscation of cells

- (void)determineIndexesOfPasswordRows {
	[super determineIndexesOfPasswordRows];
	
	[self.indexesOfPasswordRows addIndex:TPW1PasswordItemPasswordsCellPassword];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.notesPlain ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return 2;
		case 1:
			return 1; // notes
		default:
			return 0;
	}
}

- (NSString*)titleForHeaderInSection:(NSUInteger)section inTableView:(UITableView *)tableView {
	switch (section) {
		case 0:
			return nil;
		case 1:
			return NSLocalizedString(@"ui.details.notes", @"section header title for notes");
		default:
			return nil;
	}
}

- (CGFloat)preferredHeightForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	switch (indexPath.section) {
		case 0:
			return [super preferredHeightForRowAtIndexPath:indexPath inTableView:tableView];
		case 1:
			return [super preferredHeightForNotesRowInTableView:tableView];
		default:
			return 0.0;
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// notes:
	if (indexPath.section == 1) {
		return [super cellForNotesRowInTableView:tableView];
	}
	
	//load cell:
	TPWGroupedTableViewCell *cell;
	if ([self isPasswordCellAtIndexPath:indexPath]) {
		TPWObfuscatedTableViewCell *obfuscatedCell = [tableView dequeueReusableCellWithIdentifier:kTPWObfuscatedTableViewCellIdentifier];
		if (obfuscatedCell == nil) {
			obfuscatedCell = [[TPWObfuscatedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kTPWObfuscatedTableViewCellIdentifier];
		}
		obfuscatedCell.obfuscated = [self isObfuscatedCellAtIndexPath:indexPath];
		obfuscatedCell.changedBlock = ^(BOOL obfuscated) {
			if (obfuscated) {
				[self.indexesOfObfuscatedRows addIndex:indexPath.row];
			} else {
				[self.indexesOfObfuscatedRows removeIndex:indexPath.row];
			}
		};
		cell = obfuscatedCell;
	} else {
		static NSString *CellIdentifier = @"TPW1PasswordItemWebformsCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
	}
	
	//configure cell:
	switch (indexPath.row) {
		case TPW1PasswordItemPasswordsCellPassword:
			cell.position = TPWCellBackgroundViewPositionTop;
			cell.textLabel.text = NSLocalizedString(@"ui.details.passwords.password", @"key for cell 'password'");
			cell.detailTextLabel.text = self.password;
			break;
			
		case TPW1PasswordItemPasswordsCellLocation:
			cell.position = TPWCellBackgroundViewPositionBottom;
			cell.detailTextLabel.text = self.location;
			cell.textLabel.text = NSLocalizedString(@"ui.details.webforms.location", @"key for cell 'location'");
			break;
			
		default:
			break;
	}
	
	return cell;
}

- (TPW1PasswordItemActions*)actionsForRowInTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
	// notes:
	if (indexPath.section == 1) {
		return [[TPW1PasswordItemActions alloc] initWithActionsForText:self.notesPlain];
	}
	
	TPW1PasswordItemActions *actions;
	switch (indexPath.row) {
		case TPW1PasswordItemPasswordsCellPassword: {
			TPWObfuscatedTableViewCell *cell = (TPWObfuscatedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
			if (cell.isObfuscated) {
				actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:self.password dataDetectorTypes:0 onReveal:^{
					[cell revealAnimated:YES];
				}];
			} else {
				actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:self.password dataDetectorTypes:0 onHide:^{
					[cell hideAnimated:YES];
				}];
			}
			actions.showsTextInActionSheet = !cell.obfuscated;
			break;
		}
		case TPW1PasswordItemPasswordsCellLocation:
			actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:self.location];
			actions.showsTextInActionSheet = YES;
			break;
			
		default:
			NSAssert(false, @"actionsForRowInTable:atIndexPath: not implemented for indexPath %@", indexPath);
			break;
	}
	return actions;
}

@end
