//
//  UIImage+TPWImages.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 10.02.13.
//
//

#import "UIImage+TPWImages.h"

@implementation UIImage (TPWImages)

+ (UIImage *)imageWithColor:(UIColor *)color {
	CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, color.CGColor);
	CGContextFillRect(context, rect);
	UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return result;
}

- (UIImage *)sliceWithRect:(CGRect)rect {
	CGFloat scale = [UIScreen mainScreen].scale; //rescale for retina displays manually!
	CGRect retinaAdjustedRect = CGRectMake(CGRectGetMinX(rect) * scale, CGRectGetMinY(rect) * scale, CGRectGetWidth(rect) * scale, CGRectGetHeight(rect) * scale);
	CGImageRef slice = CGImageCreateWithImageInRect(self.CGImage, retinaAdjustedRect);
	UIImage *result = [UIImage imageWithCGImage:slice scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(slice);
	return result;
}

@end
