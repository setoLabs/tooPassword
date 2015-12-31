//
//  TPWTouchTransparentScrollView.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 18.10.13.
//
//

#import "TPWTouchTransparentScrollView.h"

@interface TPWTouchTransparentScrollView ()
@property (nonatomic, assign) BOOL superviewReceivedTouchEvents;
@end

@implementation TPWTouchTransparentScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self.superview touchesBegan:touches withEvent:event];
	self.superviewReceivedTouchEvents = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	[self.superview touchesCancelled:touches withEvent:event];
	self.superviewReceivedTouchEvents = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	if (self.superviewReceivedTouchEvents) {
		[self.superview touchesEnded:touches withEvent:event];
		self.superviewReceivedTouchEvents = NO;
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesCancelled:touches withEvent:event];
	if (self.superviewReceivedTouchEvents) {
		[self.superview touchesCancelled:touches withEvent:event];
		self.superviewReceivedTouchEvents = NO;
	}
}

@end
