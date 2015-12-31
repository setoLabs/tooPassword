//
//  TPWBarButtonItem.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import <UIKit/UIKit.h>

@interface TPWBarButtonItem : UIBarButtonItem

+ (UIBarButtonItem*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)tpwBackBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
