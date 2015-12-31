//
//  TPW1PasswordItemHeaderView.m
//  TooPassword
//
//  Created by Tobias Hagemann on 10/12/13.
//
//

#import "UIColor+TPWColors.h"
#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"

#import "TPW1PasswordItemHeaderView.h"

@interface TPW1PasswordItemHeaderView ()
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) NSUInteger section;
@end

@implementation TPW1PasswordItemHeaderView

- (instancetype)initWithTitle:(NSString *)title section:(NSUInteger)section {
	if (self = [super initWithFrame:CGRectZero]) {
		self.backgroundColor = [UIColor clearColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		
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
	} else if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
		leftMargin = 40.0; // iPad portrait
		topMargin = 4.0;
	} else if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		leftMargin = 52.0; // iPad landscape
		topMargin = 4.0;
	} else {
		leftMargin = 0.0; // will not happen, as all cases are covered by previous statements
		topMargin = 0.0;
	}
	
	if (self.section == 0) {
		topMargin += 20.0;
	}
	
	CGSize labelSize = [self.label sizeThatFits:CGSizeMake(CGRectGetWidth(self.frame) - leftMargin * 2.0, 0.0)];
	self.label.frame = CGRectMake(leftMargin, topMargin, labelSize.width, labelSize.height);
}

@end
