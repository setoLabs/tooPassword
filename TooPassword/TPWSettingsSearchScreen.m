//
//  TPWSettingsSearchScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 2/4/13.
//
//

#import "TPWSettings.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "TPWGroupedTableViewCell.h"

#import "TPWSettingsSearchScreen.h"

typedef enum {
	TPWSearchModeSimple,
	TPWSearchModeAdvanced
} TPWSearchMode;

NSUInteger const TPWSearchModes = 2;

@interface TPWSettingsSearchScreen ()
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *checkmarkView;
@end

@implementation TPWSettingsSearchScreen

- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"ui.modalDialogs.settingsSearchScreen.title", @"navigation bar title of setting search screen");
		self.checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
	}
	return self;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return TPWSearchModes;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//load cell:
	static NSString *CellIdentifier = @"Cell";
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	BOOL simpleSearch = [TPWSettings simpleSearch];
	
	switch (indexPath.row) {
		case TPWSearchModeSimple:
			cell.position = TPWCellBackgroundViewPositionTop;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsSearchScreen.simpleSearch", @"searchScreen mode - simple");
			if (simpleSearch) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWSearchModeAdvanced:
			cell.position = TPWCellBackgroundViewPositionBottom;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsSearchScreen.advancedSearch", @"searchScreen mode - advanced");
			if (!simpleSearch) {
				self.selectedIndexPath = indexPath;
			}
			break;
		default:
			break;
	}
	
	if (self.selectedIndexPath == indexPath) {
		cell.textLabel.textColor = [UIColor tpwOrangeColor];
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			cell.accessoryView = self.checkmarkView;
		}
	} else {
		cell.textLabel.textColor = [UIColor tpwTextColor];
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			cell.accessoryType = UITableViewCellAccessoryNone;
		} else {
			cell.accessoryView = nil;
		}
	}
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (self.selectedIndexPath) {
		UITableViewCell *selectedCellOld = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
		selectedCellOld.textLabel.textColor = [UIColor tpwTextColor];
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			selectedCellOld.accessoryType = UITableViewCellAccessoryNone;
		} else {
			selectedCellOld.accessoryView = nil;
		}
	}
	
	self.selectedIndexPath = indexPath;
	UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
	selectedCell.textLabel.textColor = [UIColor tpwOrangeColor];
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
	} else {
		selectedCell.accessoryView = self.checkmarkView;
	}
	
	BOOL simpleSearch;
	
	switch (indexPath.row) {
		case TPWSearchModeSimple:
			simpleSearch = YES;
			break;
		case TPWSearchModeAdvanced:
			simpleSearch = NO;
			break;
		default:
			simpleSearch = kTPWSettingsSimpleSearchDefaultValue;
			break;
	}
	
	[TPWSettings setSimpleSearch:simpleSearch];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
