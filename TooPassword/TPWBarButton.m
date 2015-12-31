//
//  TPWBarButton.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.01.13.
//
//

#import "TPWBarButton.h"
#import "TPWValueObserver.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"

@implementation TPWBarButton

- (void)setTpwDesignWithTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
	[super setTpwDesignWithTitleEdgeInsets:titleEdgeInsets];
	
	//title
	self.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0); //why the fuck is this a CGSize and not a UIOffset?
	self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
		
	//active
	[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor tpwShadowColor] forState:UIControlStateNormal];
	
	//highlighted
	[self setTitleColor:[UIColor tpwOrangeColor] forState:UIControlStateHighlighted];
	[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
	
	//disabled
	[self setTitleColor:[UIColor tpwLightGrayColor] forState:UIControlStateDisabled];
	[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
}

- (id)initBarButtonWithTarget:(id)target action:(SEL)action {
	if (self = [super init]) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	}
	return self;
}

- (id)initBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	if (self = [super init]) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		
		if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
			self.titleLabel.text = title;
		} else {
			[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0)];
			
			//active
			UIImage *activeBg = [[UIImage imageNamed:@"BarButton_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
			[self setTitle:title forState:UIControlStateNormal];
			[self setBackgroundImage:activeBg forState:UIControlStateNormal];
			
			//highlighted
			UIImage *highlightedBg = [[UIImage imageNamed:@"BarButton_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 2.0, 2.0)];
			[self setTitle:title forState:UIControlStateHighlighted];
			[self setBackgroundImage:highlightedBg forState:UIControlStateHighlighted];
			
			//disabled
			UIImage *disabledBg = [[UIImage imageNamed:@"BarButton_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(2.0, 2.0, 3.0, 2.0)];
			[self setTitle:title forState:UIControlStateDisabled];
			[self setBackgroundImage:disabledBg forState:UIControlStateDisabled];
		}
	}
	return self;
}

- (id)initBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	if (self = [super init]) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		
		[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 14.0, 7.0, 10.0)];
		
		//active
		UIImage *activeBg = [[UIImage imageNamed:@"BackButton_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 10.0, 15.0, 2.0)];
		[self setTitle:title forState:UIControlStateNormal];
		[self setBackgroundImage:activeBg forState:UIControlStateNormal];
		
		//highlighted
		UIImage *highlightedBg = [[UIImage imageNamed:@"BackButton_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(15.0, 10.0, 14.0, 2.0)];
		[self setTitle:title forState:UIControlStateHighlighted];
		[self setBackgroundImage:highlightedBg forState:UIControlStateHighlighted];
		
		//disabled
		UIImage *disabledBg = [[UIImage imageNamed:@"BackButton_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(14.0, 10.0, 15.0, 2.0)];
		[self setTitle:title forState:UIControlStateDisabled];
		[self setBackgroundImage:disabledBg forState:UIControlStateDisabled];
	}
	return self;
}

+ (TPWBarButton*)tpwBarButtonWithTarget:(id)target action:(SEL)action {
	return [[TPWBarButton alloc] initBarButtonWithTarget:target action:action];
}

+ (TPWBarButton*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWBarButton alloc] initBarButtonWithTitle:title target:target action:action];
}

// don't use with iOS 7
+ (TPWBarButton*)tpwBackButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWBarButton alloc] initBackButtonWithTitle:title target:target action:action];
}

@end
