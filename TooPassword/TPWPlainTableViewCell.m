//
//  TPWPlainTableViewCell.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/28/13.
//
//

#import "TPWPlainTableViewCell.h"
#import "UIColor+TPWColors.h"

@implementation TPWPlainTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.backgroundView.frame];
		
		self.textLabel.backgroundColor = [UIColor clearColor];
		self.textLabel.textColor = [UIColor tpwTextColor];
		self.textLabel.highlightedTextColor = [UIColor tpwOrangeColor];
		
		self.detailTextLabel.backgroundColor = [UIColor clearColor];
		self.detailTextLabel.textColor = [UIColor tpwDarkGrayColor];
		self.detailTextLabel.highlightedTextColor = [UIColor tpwOrangeColor];
	}
	return self;
}

@end
