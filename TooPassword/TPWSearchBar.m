//
//  TPWSearchBar.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 26.01.13.
//
//

#import "TPWSearchBar.h"
#import "TPWBarButton.h"
#import "TPWHighlightLine.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"
#import "UIImage+TPWImages.h"
#import "UITextField+TPWDesign.h"
#import "UIView+TPWBlurFix.h"
#import "TPWiOSVersions.h"

@interface TPWSearchBar ()
@property (nonatomic, strong) UIButton *customCancelButton;
@property (nonatomic, strong) TPWHighlightLine *orangeHighlightLine;
@property (nonatomic, weak) UIButton *originalCancelButton;
@property (nonatomic, weak) UITextField *searchTextField;
@end

@implementation TPWSearchBar

- (void)didMoveToSuperview {
	[super didMoveToSuperview];
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
		// enable combined status/navbar background to be drawn outside of this searchbar
		self.superview.clipsToBounds = NO;
	}
}

- (void)didAddSubview:(UIView*)subview {
	[super didAddSubview:subview];
	
	if ([subview isKindOfClass:UIButton.class] && subview != self.customCancelButton) {
		self.originalCancelButton = (UIButton*)subview;
		self.originalCancelButton.hidden = YES;
	}
	if ([subview isKindOfClass:UITextField.class]) {
		self.searchTextField = (UITextField*)subview;
		[self.searchTextField setTpwBackgroundImage];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (self.customCancelButton) {
		BOOL shouldShowCancelButton = (self.searchTextField.frame.size.width < self.bounds.size.width - 50.0);
		CGSize availableSize = self.bounds.size;
		CGSize cancelButtonSize = self.customCancelButton.frame.size;
		if (shouldShowCancelButton) {
			CGFloat marginOfButton = 5.0;
			CGFloat roomAvailableForButton = availableSize.width - self.searchTextField.frame.size.width - self.searchTextField.frame.origin.x;
			CGFloat roomStillNeededForButton = marginOfButton + cancelButtonSize.width + marginOfButton - roomAvailableForButton;
			CGRect reducedSearchTextFieldFrame = CGRectInset(self.searchTextField.frame, roomStillNeededForButton/2.0, 0.0);
			CGRect shiftedSearchTextFieldFrame = CGRectOffset(reducedSearchTextFieldFrame, -roomStillNeededForButton/2.0, 0.0);
			self.searchTextField.frame = shiftedSearchTextFieldFrame;
			self.customCancelButton.center = CGPointMake(availableSize.width - cancelButtonSize.width/2.0 - marginOfButton, self.searchTextField.center.y);
		} else {
//			self.searchTextField.frame = CGRectInset(self.bounds, 12.0, 6.0);
			self.customCancelButton.center = CGPointMake(availableSize.width + cancelButtonSize.width/2.0, self.searchTextField.center.y);
		}
		[self.customCancelButton fixBlur];
	}
}

#pragma mark - dispatching ui events

- (void)pressedCustomCancelButton:(id)sender {
	[self.originalCancelButton sendActionsForControlEvents:UIControlEventTouchUpInside];
	[self willEndSearchAnimated:YES];
}

#pragma mark - animating cancel button

- (void)willBeginSearchAnimated:(BOOL)animated {
	self.backgroundColor = [UIColor tpwGrayColor];
	self.backgroundImage = [UIImage imageNamed:@"SearchbarBackground"];
	if ([self respondsToSelector:@selector(searchBarStyle)]) {
		self.searchBarStyle = UISearchBarStyleDefault;
	}
	
	if (animated) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
			self.customCancelButton.alpha = 1.0;
			self.orangeHighlightLine.alpha = 1.0;
		} completion:nil];
	} else {
		self.customCancelButton.alpha = 1.0;
		self.orangeHighlightLine.alpha = 1.0;
	}
}

- (void)willEndSearchAnimated:(BOOL)animated {
	self.backgroundColor = [UIColor tpwTableViewCellColor];
	self.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
	if ([self respondsToSelector:@selector(searchBarStyle)]) {
		self.searchBarStyle = UISearchBarStyleMinimal;
	}
	
	if (animated) {
		[UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
			self.customCancelButton.alpha = 0.0;
			self.orangeHighlightLine.alpha = 0.0;
		} completion:nil];
	} else {
		self.customCancelButton.alpha = 0.0;
		self.orangeHighlightLine.alpha = 0.0;
	}
}

#pragma mark - adjusting size of custom button

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (object == self.customCancelButton.titleLabel && [keyPath isEqualToString:@"text"]) {
		[self adjustCustomCancelButtonSize];
	}
}

- (void)adjustCustomCancelButtonSize {
	CGSize sizeThatFits = [self.customCancelButton sizeThatFits:self.bounds.size];
	CGPoint currentCenter = self.customCancelButton.center;
	UIEdgeInsets titleInsets = self.customCancelButton.titleEdgeInsets;
	self.customCancelButton.frame = CGRectMake(0.0, 0.0, titleInsets.left+sizeThatFits.width+titleInsets.right, titleInsets.top+sizeThatFits.height+titleInsets.bottom);
	self.customCancelButton.center = currentCenter;
	[self.customCancelButton fixBlur];
}

#pragma mark - lifecycle

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		//background
		self.backgroundColor = [UIColor tpwTableViewCellColor];
		self.backgroundImage = [UIImage imageWithColor:[UIColor clearColor]];
		if ([self respondsToSelector:@selector(setBackgroundImage:forBarPosition:barMetrics:)]) {
			[self setBackgroundImage:[UIImage imageNamed:@"SearchbarBackground-64"] forBarPosition:UIBarPositionTopAttached barMetrics:UIBarMetricsDefault];
		}
		
		//highlight line
		self.orangeHighlightLine = [[TPWHighlightLine alloc] initWithFrame:CGRectMake(0.0, frame.size.height - 1.0, frame.size.width, 1.0)];
		[self addSubview:self.orangeHighlightLine];
		
		//search bar style
		if ([self respondsToSelector:@selector(searchBarStyle)]) {
			self.searchBarStyle = UISearchBarStyleMinimal;
		}
		
		//custom cancel button
		if ([TPWiOSVersions isLessThanVersion:@"7.0"]) {
			self.customCancelButton = [TPWBarButton tpwBarButtonWithTitle:NSLocalizedString(@"ui.common.cancel", @"cancel") target:self action:@selector(pressedCustomCancelButton:)];
			[self.customCancelButton.titleLabel addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
			[self adjustCustomCancelButtonSize];
			[self addSubview:self.customCancelButton];
		}
		
		//hide subviews
		[self willEndSearchAnimated:NO];
	}
	return self;
}

- (void)dealloc {
	[self.customCancelButton.titleLabel removeObserver:self forKeyPath:@"text"];
}

@end
