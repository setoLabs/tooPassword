//
//  TPWBarButtonItem.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import "TPWBarButtonItem.h"
#import "TPWBarButton.h"
#import "UIColor+TPWColors.h"

@implementation TPWBarButtonItem

- (id)initWithTpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	TPWBarButton *button = [TPWBarButton tpwBarButtonWithTitle:title target:target action:action];
	if (self = [super initWithCustomView:button]) {
		UIEdgeInsets titleInsets = button.titleEdgeInsets;
		CGSize bestTitleSize = [button.titleLabel sizeThatFits:CGSizeZero];
		CGRect suggestedFrame = CGRectMake(0.0, 0.0, titleInsets.left+bestTitleSize.width+titleInsets.right, titleInsets.top+bestTitleSize.height+titleInsets.bottom);
		button.frame = suggestedFrame;
	}
	return self;
}

- (id)initWithTpwBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	TPWBarButton *button = [TPWBarButton tpwBackButtonWithTitle:title target:target action:action];
	if (self = [super initWithCustomView:button]) {
		UIEdgeInsets titleInsets = button.titleEdgeInsets;
		CGSize bestTitleSize = [button.titleLabel sizeThatFits:CGSizeZero];
		CGRect suggestedFrame = CGRectMake(0.0, 0.0, titleInsets.left+bestTitleSize.width+titleInsets.right, titleInsets.top+bestTitleSize.height+titleInsets.bottom);
		button.frame = suggestedFrame;
	}
	return self;
}

+ (UIBarButtonItem*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWBarButtonItem alloc] initWithTpwBarButtonWithTitle:title target:target action:action];
}

+ (UIBarButtonItem*)tpwBackBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWBarButtonItem alloc] initWithTpwBackButtonWithTitle:title target:target action:action];
}

@end
