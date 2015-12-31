//
//  TPWBarButton.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWButton.h"

@interface TPWBarButton : TPWButton

- (id)initBarButtonWithTarget:(id)target action:(SEL)action;
- (id)initBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
- (id)initBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action; // don't use with iOS 7

+ (TPWBarButton*)tpwBarButtonWithTarget:(id)target action:(SEL)action;
+ (TPWBarButton*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;
+ (TPWBarButton*)tpwBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action; // don't use with iOS 7

@end
