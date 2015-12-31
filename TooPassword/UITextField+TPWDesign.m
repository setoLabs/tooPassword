//
//  UITextField+TPWDesign.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 10.02.13.
//
//

#import "UITextField+TPWDesign.h"
#import "UIImage+TPWImages.h"

@implementation UITextField (TPWDesign)

- (void)setTpwBackgroundImage {
	self.background = [[UIImage imageNamed:@"TextfieldBackground"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 3.0, 2.0)];
}

- (void)setTpwBackgroundImageAndCutOffRightBorder {
	self.background = [[[UIImage imageNamed:@"TextfieldBackground"] sliceWithRect:CGRectMake(0.0, 0.0, 3.0, 7.0)] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 3.0, 0.0)];
}

@end
