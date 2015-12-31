//
//  TPWSettingsAutoLockScreen.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/25/13.
//
//

#import "TPWSettings.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "TPWGroupedTableViewCell.h"

#import "TPWSettingsAutoLockScreen.h"

typedef enum {
	TPWAutoLockTimeIntervalInstant,
	TPWAutoLockTimeInterval60,
	TPWAutoLockTimeInterval120,
	TPWAutoLockTimeInterval300,
	TPWAutoLockTimeInterval600
} TPWAutoLockTimeInterval;

NSUInteger const TPWAutoLockTimeIntervals = 5;

@interface TPWSettingsAutoLockScreen ()
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *checkmarkView;
@end

@implementation TPWSettingsAutoLockScreen

- (id)init {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.title = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.title", @"navigation bar title of setting auto lock screen");
		self.checkmarkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
	}
	return self;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return TPWAutoLockTimeIntervals;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	//load cell:
	static NSString *CellIdentifier = @"Cell";
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
	}
	
	NSTimeInterval autoLockTimeInterval = [TPWSettings autoLockTimeInterval];
	
	switch (indexPath.row) {
		case TPWAutoLockTimeIntervalInstant:
			cell.position = TPWCellBackgroundViewPositionTop;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.instantAutoLock", @"autoLockScreen timeInterval - instant");
			if (autoLockTimeInterval == kTPWSettingsAutoLockTimeIntervalInstant) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWAutoLockTimeInterval60:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.autoLockAfter60s", @"autoLockScreen timeInterval - 60s");
			if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval60) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWAutoLockTimeInterval120:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.autoLockAfter120s", @"autoLockScreen timeInterval - 120s");
			if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval120) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWAutoLockTimeInterval300:
			cell.position = TPWCellBackgroundViewPositionMiddle;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.autoLockAfter300s", @"autoLockScreen timeInterval - 300s");
			if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval300) {
				self.selectedIndexPath = indexPath;
			}
			break;
		case TPWAutoLockTimeInterval600:
			cell.position = TPWCellBackgroundViewPositionBottom;
			cell.textLabel.text = NSLocalizedString(@"ui.modalDialogs.settingsAutoLockScreen.autoLockAfter600s", @"autoLockScreen timeInterval - 600s");
			if (autoLockTimeInterval == kTPWSettingsAutoLockTimeInterval600) {
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
	
	NSTimeInterval autoLockTimeInterval;
	
	switch (indexPath.row) {
		case TPWAutoLockTimeIntervalInstant:
			autoLockTimeInterval = kTPWSettingsAutoLockTimeIntervalInstant;
			break;
		case TPWAutoLockTimeInterval60:
			autoLockTimeInterval = kTPWSettingsAutoLockTimeInterval60;
			break;
		case TPWAutoLockTimeInterval120:
			autoLockTimeInterval = kTPWSettingsAutoLockTimeInterval120;
			break;
		case TPWAutoLockTimeInterval300:
			autoLockTimeInterval = kTPWSettingsAutoLockTimeInterval300;
			break;
		case TPWAutoLockTimeInterval600:
			autoLockTimeInterval = kTPWSettingsAutoLockTimeInterval600;
			break;
		default:
			autoLockTimeInterval = kTPWSettingsAutoLockDefaultValue;
			break;
	}
	
	[TPWSettings setAutoLockTimeInterval:autoLockTimeInterval];
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
