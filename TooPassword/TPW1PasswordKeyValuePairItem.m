//
//  TPW1PasswordKeyValuePairItem.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import "TPW1PasswordKeyValuePairItem.h"
#import "TPWGroupedTableViewCell.h"
#import "TPWObfuscatedTableViewCell.h"
#import "UIFont+TPWFonts.h"
#import "NSString+TPWExtensions.h"

@implementation TPW1PasswordKeyValuePairItem

#pragma mark - searching

- (BOOL)matchesSearchTerm:(NSString*)word searchTitleOnly:(BOOL)simpleSearch {
	if (simpleSearch) {
		return [super matchesSearchTerm:word searchTitleOnly:simpleSearch];
	}
	NSMutableString *haystack = [[NSString haystackUsingHay:self.title ? : @"", self.location ? : @"", self.notesPlain ? : @"", nil] mutableCopy];
	[self.keyValuePairs enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
		NSString *value = [obj description];
		if (![[TPW1PasswordFieldKeyUtil sharedInstance] shouldObfuscateValueForKey:key] && [value length] > 0) {
			[haystack appendString:@" "];
			[haystack appendString:value];
		}
	}];
	return [haystack rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound;
}

#pragma mark - decryption

- (void)didDecrypt:(NSDictionary*)decrypted {
	[super didDecrypt:decrypted];
	NSMutableDictionary *dict;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		dict = [[TPW1PasswordFieldKeyUtil sharedInstance] shortenedTidyFieldDictionaryFromRawDictionary:decrypted];
	} else {
		dict = [[TPW1PasswordFieldKeyUtil sharedInstance] tidyFieldDictionaryFromRawDictionary:decrypted];
	}
	[dict removeObjectForKey:kTPW1PasswordItemJsonKeyNotesPlain]; // notes are in a separate section
	self.keys = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2) {
		return [key1 compare:key2];
	}];
	self.keyValuePairs = dict;
}

#pragma mark - obfuscation of cells

- (void)determineIndexesOfPasswordRows {
	[super determineIndexesOfPasswordRows];
	
	for (NSInteger row = 0; row < self.keys.count; row++) {
		NSString *key = self.keys[row];
		if ([[TPW1PasswordFieldKeyUtil sharedInstance] shouldObfuscateValueForKey:key]) {
			[self.indexesOfPasswordRows addIndex:row];
		}
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (self.notesPlain && [self.notesPlain length] > 0) ? 2 : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case 0:
			return self.keys.count;
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
		static NSString *CellIdentifier = @"TPW1PasswordKeyValuePairCell";
		cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
		if (cell == nil) {
			cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
		}
	}
	
	//configure cell:
	if ([self.keys count] == 1) {
		cell.position = TPWCellBackgroundViewPositionSingle;
	} else if (indexPath.row == 0) {
		cell.position = TPWCellBackgroundViewPositionTop;
	} else if (indexPath.row == [self.keys count] - 1) {
		cell.position = TPWCellBackgroundViewPositionBottom;
	} else {
		cell.position = TPWCellBackgroundViewPositionMiddle;
	}
	
	//get keyValuePair:
	NSString *key = self.keys[indexPath.row];
	NSString *value = self.keyValuePairs[key];
	if (![value isKindOfClass:NSString.class]) {
		NSAssert([value respondsToSelector:@selector(description)], @"%@ was stored in a dictionary but is not a NSObject? can not be.", value);
		value = value.description;
	}
	
	cell.detailTextLabel.text = value;
	cell.textLabel.text = [[NSBundle mainBundle] localizedStringForKey:key value:key table:kTPW1PasswordFieldLocalizationTable];
	
	return cell;
}

- (TPW1PasswordItemActions*)actionsForRowInTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
	// notes:
	if (indexPath.section == 1) {
		return [[TPW1PasswordItemActions alloc] initWithActionsForText:self.notesPlain];
	}
	
	NSString *key = self.keys[indexPath.row];
	NSString *value = self.keyValuePairs[key];
	TPW1PasswordItemActions *actions;
	if ([self isPasswordCellAtIndexPath:indexPath]) {
		TPWObfuscatedTableViewCell *cell = (TPWObfuscatedTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
		if (cell.isObfuscated) {
			actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:value dataDetectorTypes:0 onReveal:^{
				[cell revealAnimated:YES];
			}];
		} else {
			actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:value dataDetectorTypes:0 onHide:^{
				[cell hideAnimated:YES];
			}];
		}
		actions.showsTextInActionSheet = !cell.obfuscated;
	} else {
		actions = [[TPW1PasswordItemActions alloc] initWithActionsForText:value];
		actions.showsTextInActionSheet = YES;
	}
	return actions;
}

@end
