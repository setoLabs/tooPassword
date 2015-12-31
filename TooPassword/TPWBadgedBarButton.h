//
//  TPWBadgedBarButton.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.02.13.
//
//

#import "TPWBarButton.h"
#import "SPCustomBadge.h"

@interface TPWBadgedBarButton : TPWBarButton

@property (nonatomic, strong) SPCustomBadge *badge;
@property (nonatomic, assign) BOOL showBadge;

+ (TPWBadgedBarButton*)tpwBarButtonWithTarget:(id)target action:(SEL)action;
+ (TPWBadgedBarButton*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
