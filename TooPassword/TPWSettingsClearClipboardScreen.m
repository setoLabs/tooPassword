//
//  TPWSettingsClearClipboardScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/25/13.
//
//

#import "TPWSettings.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "TPWGroupedTableViewCell.h"

#import "TPWSettingsClearClipboardScreen.h"

typedef enum {
	TPWClearClipboardTimeInterval30,
	TPWClearClipboardTimeInterval60,
	TPWClearClipboardTimeInterval120,
	TPWClearClipboardTimeInterval300,
	TPWClearClipboardTimeIntervalNever
} TPWClearClipboardTimeInterval;

NSUInteger const kTPWClearClipboardTimeIntervals = 5;

@interface TPWSettingsClearClipboardScreen ()
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *checkmarkView;
@end

@implementation TPWSettingsClearClipboardScreen

- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.title", @"navigation bar title of settings clear clipboard screen");
		self.checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
	}
	return self;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return kTPWClearClipboardTimeIntervals;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//load cell:
	static NSString *CellIdentifier = @"Cell";
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	NSTimeInterval clearClipboardTimeInterval = [TPWSettings clearClipboardTimeInterval];
	
	switch (indexPath.row) {
		case TPWClearClipboardTimeInterval30:
			cell.position = TPWCellBackgroundViewPositionTop;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.clearClipboardAfter30s", @"clearClipboardScreen timeInterval - 30s");
			if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval30) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWClearClipboardTimeInterval60:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.clearClipboardAfter60s", @"clearClipboardScreen timeInterval - 60s");
			if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval60) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWClearClipboardTimeInterval120:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.clearClipboardAfter120s", @"clearClipboardScreen timeInterval - 120s");
			if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval120) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWClearClipboardTimeInterval300:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.clearClipboardAfter300s", @"clearClipboardScreen timeInterval - 300s");
			if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeInterval300) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWClearClipboardTimeIntervalNever:
			cell.position = TPWCellBackgroundViewPositionBottom;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsClearClipboardScreen.clearClipboardDisabled", @"clearClipboardScreen timeInterval - Disabled");
			if (clearClipboardTimeInterval == kTPWSettingsClearClipboardTimeIntervalNever) {
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
	
	NSTimeInterval clearClipboardTimeInterval;
	
	switch (indexPath.row) {
		case TPWClearClipboardTimeInterval30:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardTimeInterval30;
			break;
		case TPWClearClipboardTimeInterval60:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardTimeInterval60;
			break;
		case TPWClearClipboardTimeInterval120:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardTimeInterval120;
			break;
		case TPWClearClipboardTimeInterval300:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardTimeInterval300;
			break;
		case TPWClearClipboardTimeIntervalNever:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardTimeIntervalNever;
			break;
		default:
			clearClipboardTimeInterval = kTPWSettingsClearClipboardDefaultValue;
			break;
	}
	
	[TPWSettings setClearClipboardTimeInterval:clearClipboardTimeInterval];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
