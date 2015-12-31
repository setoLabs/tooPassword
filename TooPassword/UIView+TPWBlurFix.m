//
//  UIView+TPWBlurFix.m
//  TooPassword
//
//  Created by Tobias Hagemann on 8/27/13.
//
//

#import "UIView+TPWBlurFix.h"

@implementation UIView (TPWBlurFix)

- (void)fixBlur {
	CGRect roundedFrame = CGRectMake(floor(self.frame.origin.x), floor(self.frame.origin.y), self.frame.size.width, self.frame.size.height);
	self.frame = roundedFrame;
}

@end
