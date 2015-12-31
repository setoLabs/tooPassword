//
//  TPWTextfieldButton.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 10.02.13.
//
//

#import "TPWTextfieldButton.h"
#import "UIColor+TPWColors.h"

@implementation TPWTextfieldButton

- (void)setTpwDesignWithTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets {
	//title
	self.titleLabel.shadowOffset = CGSizeMake(0.0, 1.0); //why the fuck is this a CGSize and not a UIOffset?
	self.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
	
	//active
	UIImage *activeBg = [[UIImage imageNamed:@"TextfieldButton_active"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 3.0, 2.0)];
	[self setBackgroundImage:activeBg forState:UIControlStateNormal];
	[self setTitleColor:[UIColor tpwTextColor] forState:UIControlStateNormal];
	[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateNormal];
	
	//highlighted
	UIImage *higlightedBg = [[UIImage imageNamed:@"TextfieldButton_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 3.0, 2.0)];
	[self setBackgroundImage:higlightedBg forState:UIControlStateHighlighted];
	[self setTitleColor:[UIColor tpwTextColor] forState:UIControlStateHighlighted];
	[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateHighlighted];
	
	//disabled
	UIImage *disabledBg = [[UIImage imageNamed:@"TextfieldButton_disabled"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 2.0, 3.0, 2.0)];
	[self setBackgroundImage:disabledBg forState:UIControlStateDisabled];
	[self setTitleColor:[UIColor tpwLightGrayColor] forState:UIControlStateDisabled];
	[self setTitleShadowColor:[UIColor clearColor] forState:UIControlStateDisabled];
}

- (id)initTextfieldButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	if (self = [super init]) {
		[self addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
		
		[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0)];
		
		[self setTitle:title forState:UIControlStateNormal];
		[self setTitle:title forState:UIControlStateHighlighted];
		[self setTitle:title forState:UIControlStateDisabled];
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super initWithCoder:aDecoder]) {
		[self setTpwDesignWithTitleEdgeInsets:UIEdgeInsetsMake(7.0, 10.0, 7.0, 10.0)];
	}
	return self;
}

+ (TPWButton*)tpwTextfieldButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWTextfieldButton alloc] initTextfieldButtonWithTitle:title target:target action:action];
}

@end
