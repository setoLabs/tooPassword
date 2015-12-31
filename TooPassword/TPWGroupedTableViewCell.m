//
//  TPWGroupedTableViewCell.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/28/13.
//
//

#import "TPWGroupedTableViewCell.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"

@implementation TPWGroupedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor tpwTextColor];
		
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.textColor = [UIColor tpwDarkGrayColor];
		self.detailTextLabel.font = [UIFont tpwDefaultFont];
	}
	return self;
}

- (void)setPosition:(TPWCellBackgroundViewPosition)position {
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		// just ignore this piece of crap
		return;
	}
	
	UIImage *activeBg;
	UIImage *highlightedBg;
	
	switch (position) {
		case TPWCellBackgroundViewPositionSingle:
			activeBg = [[UIImage imageNamed:@"GroupedTableViewCellSingle_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 3.0, 6.0, 3.0)];
			highlightedBg = [[UIImage imageNamed:@"GroupedTableViewCellSingle_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 3.0, 6.0, 3.0)];
			break;
		case TPWCellBackgroundViewPositionTop:
			activeBg = [[UIImage imageNamed:@"GroupedTableViewCellTop_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 3.0, 3.0, 3.0)];
			highlightedBg = [[UIImage imageNamed:@"GroupedTableViewCellTop_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 3.0, 3.0, 3.0)];
			break;
		case TPWCellBackgroundViewPositionMiddle:
			activeBg = [[UIImage imageNamed:@"GroupedTableViewCellMiddle_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
			highlightedBg = [[UIImage imageNamed:@"GroupedTableViewCellMiddle_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
			break;
		case TPWCellBackgroundViewPositionBottom:
			activeBg = [[UIImage imageNamed:@"GroupedTableViewCellBottom_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 3.0, 6.0, 3.0)];
			highlightedBg = [[UIImage imageNamed:@"GroupedTableViewCellBottom_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 3.0, 6.0, 3.0)];
			break;
		default:
			break;
	}
	
	self.backgroundView = [[UIImageView alloc] initWithImage:activeBg];
	self.selectedBackgroundView = [[UIImageView alloc] initWithImage:highlightedBg];
}

@end
