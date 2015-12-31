//
//  TPWButton.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/31/13.
//
//

#import "TPWButton.h"
#import "TPWValueObserver.h"
#import "UIColor+TPWColors.h"
#import "TPWiOSVersions.h"

@interface TPWButton ()
@property (nonatomic, strong) TPWValueObserver *buttonStateObserver;
@end

@implementation TPWButton

- (void)setTpwDesignWithTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
	//title
	self.titleLabel.font = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? [UIFont systemFontOfSize:15.0] : [UIFont boldSystemFontOfSize:15.0];
	self.titleEdgeInsets = titleEdgeInsets;
	__block UIEdgeInsets imageEdgeInsets = self.imageEdgeInsets;
	self.buttonStateObserver = [self observeValueForKeyPath:@"highlighted" onChange:^(NSDictionary *change) {
		NSNumber *newValue = change[NSKeyValueChangeNewKey];
		if ([newValue boolValue]) {
			self.imageEdgeInsets = UIEdgeInsetsMake(imageEdgeInsets.top+1, imageEdgeInsets.left, imageEdgeInsets.bottom-1, imageEdgeInsets.right);
			self.titleEdgeInsets = UIEdgeInsetsMake(titleEdgeInsets.top+1, titleEdgeInsets.left, titleEdgeInsets.bottom-1, titleEdgeInsets.right);
		} else {
			self.imageEdgeInsets = imageEdgeInsets;
			self.titleEdgeInsets = titleEdgeInsets;
		}
	}];
	
	//active
	UIImage *activeBg = [[UIImage imageNamed:@"Button_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 6.0, 5.0)];
	[self setBackgroundImage:activeBg forState:UIControlStateNormal];
	[self setTitleColor:[UIColor tpwTextColor] forState:UIControlStateNormal];
	
	//highlighted
	UIImage *higlightedBg = [[UIImage imageNamed:@"Button_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(6.0, 5.0, 5.0, 5.0)];
	[self setBackgroundImage:higlightedBg forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor tpwOrangeColor] forState:UIControlStateHighlighted];
	
	//disabled
	UIImage *disabledBg = [[UIImage imageNamed:@"Button_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(5.0, 5.0, 6.0, 5.0)];
	[self setBackgroundImage:disabledBg forState:UIControlStateDisabled];
	[self setTitleColor:[UIColor tpwLightGrayColor] forState:UIControlStateDisabled];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0)];
	}
	return self;
}

- (id)initButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	if (self = [super init]) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		
		[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0)];
		
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateHighlighted];
		[self setTitle:title forState:UIControlStateDisabled];
	}
	return self;
}

+ (TPWButton *)tpwButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWButton alloc] initButtonWithTitle:title target:target action:action];
}

@end
