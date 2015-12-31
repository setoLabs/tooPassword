//
//  TPWHighlightLine.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/30/13.
//
//

#import "UIColor+TPWColors.h"
#import "TPWHighlightLine.h"

@implementation TPWHighlightLine

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	NSArray *gradientColors = @[
		(__bridge id)[[UIColor tpwOrangeColor] colorWithAlphaComponent:0.3].CGColor,
		(__bridge id)[UIColor tpwOrangeColor].CGColor,
		(__bridge id)[UIColor tpwOrangeColor].CGColor,
		(__bridge id)[[UIColor tpwOrangeColor] colorWithAlphaComponent:0.3].CGColor
	];
	
	CGFloat gradientLocations[] = { 0.0, 0.1, 0.9, 1.0 };
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)gradientColors, gradientLocations);
	CGPoint startPoint = CGPointMake(0.0, 0.0);
	CGPoint endPoint = CGPointMake(CGRectGetMaxX(self.frame), 0.0);
	
	CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
	
	// Clean up, because ARC doesn't handle CG.
	CGColorSpaceRelease(colorSpace);
	CGGradientRelease(gradient);
}

@end
