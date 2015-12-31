//
//  TPWSectionHeaderView.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import "TPWSectionHeaderView.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"

CGFloat const kTPWSectionHeaderViewHeight = 20.0;
CGFloat const kTPWSectionHeaderViewWidth = 320.0; //tableview width for all devices

@implementation TPWSectionHeaderView

- (id)initWithText:(NSString*)text {
	if (self = [super initWithFrame:CGRectMake(0.0, 0.0, kTPWSectionHeaderViewWidth, kTPWSectionHeaderViewHeight)]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		self.backgroundColor = [UIColor tpwTableViewCellColor];
		self.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
		self.text = text;
		self.textColor = [UIColor tpwPaleOrangeColor];
		self.textAlignment = NSTextAlignmentCenter;
		self.font = [UIFont boldSystemFontOfSize:12.0];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGColorSpaceRef deviceColorSpace = CGColorSpaceCreateDeviceRGB();

	CGContextSaveGState(context);
	CGContextSetFillColorWithColor(context, [self.backgroundColor CGColor]);
	CGContextFillRect(context, self.bounds);
	CGContextRestoreGState(context);
	
	//draw highlight line
	NSArray *lineGradientColors = @[
		(__bridge id)[[[UIColor tpwOrangeColor] colorWithAlphaComponent:0.2] CGColor],
		(__bridge id)[[UIColor tpwPaleOrangeColor] CGColor],
		(__bridge id)[[[UIColor tpwOrangeColor] colorWithAlphaComponent:0.2] CGColor]
	];
	
	CGFloat lineGradientLocations[] = {0.4, 0.5, 0.6};
	
	CGPoint lineGradientStart = CGPointMake(0.0, CGRectGetMaxY(self.bounds));
	CGPoint lienGradientEnd = CGPointMake(CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
	CGRect lineRect = CGRectMake(0.0, CGRectGetMaxY(self.bounds)-1.0, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
	
	CGGradientRef lineGradient = CGGradientCreateWithColors(deviceColorSpace, (__bridge CFArrayRef)lineGradientColors, lineGradientLocations);
	CGContextSaveGState(context);
	CGContextClipToRect(context, lineRect);
	CGContextDrawLinearGradient(context, lineGradient, lineGradientStart, lienGradientEnd, 0);
	CGGradientRelease(lineGradient);
	CGContextRestoreGState(context);
	
	CGColorSpaceRelease(deviceColorSpace);
	
	//draw text
	[self drawTextInRect:self.bounds];
}

@end
