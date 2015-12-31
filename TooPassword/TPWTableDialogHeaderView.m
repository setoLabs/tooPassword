//
//  TPWTableDialogHeaderView.m
//  TooPassword
//
//  Created by Tobias Hagemann on 02/02/14.
//
//

#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"

#import "TPWTableDialogHeaderView.h"

@interface TPWTableDialogHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSInteger section;
@end

@implementation TPWTableDialogHeaderView

- (instancetype)initWithTitle:(NSString *)title section:(NSUInteger)section {
	if (self = [super initWithFrame:CGRectZero]) {
		self.backgroundColor = [UIColor clearColor];
		
		self.label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.label.backgroundColor = [UIColor clearColor];
		self.label.font = [UIFont tpwSubheadlineFont];
		self.label.text = title;
		self.label.textColor = [UIColor tpwDarkGrayColor];
		if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
			self.label.shadowColor = [UIColor whiteColor];
			self.label.shadowOffset = CGSizeMake(0.0, 1.0);
		}
		self.label.numberOfLines = 0;
		[self addSubview:self.label];
		
		self.section = section;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat leftMargin;
	CGFloat topMargin;
	
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		leftMargin = 15.0;
		topMargin = 5.0;
	} else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		leftMargin = 19.0; // iPhone
		topMargin = 6.0;
	} else {
		leftMargin = 40.0; // iPad
		topMargin = 4.0;
	}
	
	if (self.section == 0) {
		topMargin += 20.0;
	}
	
	CGSize labelSize = [self.label sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - leftMargin * 2.0, 0.0)];
	self.label.frame = CGRectMake(leftMargin, topMargin, labelSize.width, labelSize.height);
}

@end
