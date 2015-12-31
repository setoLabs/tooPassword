//
//  TPWBadgedBarButton.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.02.13.
//
//

#import "TPWBadgedBarButton.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"

NSString *const kTPWBadgedBarButtonDefaultBadgeTitle = @"1";

@implementation TPWBadgedBarButton

- (id)initBadgedBarButtonWithTarget:(id)target action:(SEL)action {
	if (self = [super initBarButtonWithTarget:target action:action]) {
		BOOL drawWithBadgeFrame = [TPWiOSVersions isLessThanVersion:@"7.0"];
		self.badge = [SPCustomBadge customBadgeWithString:kTPWBadgedBarButtonDefaultBadgeTitle withStringColor:[UIColor whiteColor] withInsetColor:[UIColor tpwOrangeColor] withBadgeFrame:drawWithBadgeFrame withBadgeFrameColor:[UIColor whiteColor] withScale:0.65 withShining:NO];
		self.badge.userInteractionEnabled = NO;
		self.badge.hidden = YES;
		[self addSubview:self.badge];
	}
	return self;
}

- (id)initBadgedBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	if (self = [super initBarButtonWithTitle:title target:target action:action]) {
		self.badge = [SPCustomBadge customBadgeWithString:kTPWBadgedBarButtonDefaultBadgeTitle withStringColor:[UIColor whiteColor] withInsetColor:[UIColor tpwOrangeColor] withBadgeFrame:YES withBadgeFrameColor:[UIColor whiteColor] withScale:0.65 withShining:NO];
		self.badge.userInteractionEnabled = NO;
		self.badge.hidden = YES;
		[self addSubview:self.badge];
	}
	return self;
}

+ (TPWBadgedBarButton*)tpwBarButtonWithTarget:(id)target action:(SEL)action {
	return [[TPWBadgedBarButton alloc] initBadgedBarButtonWithTarget:target action:action];
}

+ (TPWBadgedBarButton*)tpwBarButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action {
	return [[TPWBadgedBarButton alloc] initBadgedBarButtonWithTitle:title target:target action:action];
}

#pragma mark -

- (void)setEnabled:(BOOL)enabled {
	[super setEnabled:enabled];
	if (enabled) {
		self.badge.badgeInsetColor = [UIColor tpwOrangeColor];
	} else {
		self.badge.badgeInsetColor = [UIColor tpwLightGrayColor];
	}
	[self.badge setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted {
	[super setHighlighted:highlighted];
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		self.badge.badgeInsetColor = highlighted ? [[UIColor tpwOrangeColor] colorWithAlphaComponent:0.2] : [UIColor tpwOrangeColor];
		self.badge.badgeTextColor = highlighted ? [UIColor colorWithWhite:1.0 alpha:0.2] : [UIColor whiteColor];
	} else {
		self.badge.badgeShadow = !highlighted;
	}
	[self.badge setNeedsDisplay];
}

- (void)setShowBadge:(BOOL)show {
	_showBadge = show;
	self.badge.hidden = !show;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	CGSize badgeSize = self.badge.frame.size;
	CGFloat originX = floorf(self.bounds.size.width - badgeSize.width * 0.6);
	CGFloat originY = floorf(-badgeSize.height * 0.4);
	if (self.highlighted && [TPWiOSVersions isLessThanVersion:@"7.0"]) {
		originY += 1.0;
	}
	self.badge.frame = CGRectMake(originX, originY, badgeSize.width, badgeSize.height);
}

@end
