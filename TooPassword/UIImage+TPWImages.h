//
//  UIImage+TPWImages.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 10.02.13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (TPWImages)

+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)sliceWithRect:(CGRect)rect;

@end
