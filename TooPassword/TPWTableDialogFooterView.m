//
//  TPWTableDialogFooterView.m
//  TooPassword
//
//  Created by Tobias Hagemann on 02/02/14.
//
//

#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"

#import "TPWTableDialogFooterView.h"

@interface TPWTableDialogFooterView ()
@property (nonatomic, strong) UILabel *label;
@end

@implementation TPWTableDialogFooterView

- (instancetype)initWithTitle:(NSString *)title {
	if (self = [super initWithFrame:CGRectZero]) {
		self.backgroundColor = [UIColor clearColor];
		
		self.label = [[UILabel alloc] initWithFrame:CGRectZero];
		self.label.backgroundColor = [UIColor clearColor];
		self.label.font = [UIFont tpwFootnoteFont];
		self.label.textAlignment = NSTextAlignmentCenter;
		self.label.text = title;
		self.label.textColor = [UIColor tpwDarkGrayColor];
		if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
			self.label.shadowColor = [UIColor whiteColor];
			self.label.shadowOffset = CGSizeMake(0.0, 1.0);
		}
		self.label.numberOfLines = 0;
		[self addSubview:self.label];
	}
	return self;
}

- (void)layoutSubviews {
	CGFloat leftMargin;
	CGFloat topMargin;
	
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		leftMargin = 19.0; // iPhone
		topMargin = 5.0;
	} else {
		leftMargin = 40.0; // iPad
		topMargin = 5.0;
	}
	
	CGSize labelSize = [self.label sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - leftMargin * 2.0, 0.0)];
	self.label.frame = CGRectMake(leftMargin, topMargin, CGRectGetWidth(self.frame) - leftMargin * 2.0, labelSize.height);
}

@end
