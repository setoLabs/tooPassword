//
//  TPWButton.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/31/13.
//
//

#import <UIKit/UIKit.h>

@interface TPWButton : UIButton

- (void)setTpwDesignWithTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

+ (TPWButton *)tpwButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
