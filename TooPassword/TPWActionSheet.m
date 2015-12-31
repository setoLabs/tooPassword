//
//  TPWActionSheet.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.02.13.
//
//

#import "TPWActionSheet.h"
#import "UIFont+TPWFonts.h"

CGFloat const kTPWActionSheetButtonPaddings = 20;
CGFloat const kTPWActionSheetLabelOffset = 51.0; // = 10(offset)+40(width)+8(gap)-7(inset)
CGFloat const kTPWActionSheetImageViewWidthWithGap = 48.0;
CGFloat const kTPWActionSheetImageViewOffset = 41.0; // = 40(width)+8(gap)-7(inset)

static NSInteger kTPWActionSheetObserverContextsButtonLabel;
static NSInteger kTPWActionSheetObserverContextsButtonImage;
static NSInteger kTPWActionSheetObserverContextsLabel;

@implementation TPWActionSheet

- (void)dealloc {
	[self unregisterObserverForActionSheetDismissal];
	
	// unregister from observed buttons
	NSIndexSet *indexesOfButtons = [self.subviews indexesOfObjectsPassingTest:^BOOL(UIView *subview, NSUInteger idx, BOOL *stop) {
		return [subview isKindOfClass:UIButton.class];
	}];
	NSArray *buttons = [self.subviews objectsAtIndexes:indexesOfButtons];
	for (UIButton *button in buttons) {
		if (button.imageView.image) {
			[button.titleLabel removeObserver:self forKeyPath:@"frame"];
			[button.imageView removeObserver:self forKeyPath:@"frame"];
		}
	}
	
	// unregister from observed labels
	NSIndexSet *indexesOfLabels = [self.subviews indexesOfObjectsPassingTest:^BOOL(UIView *subview, NSUInteger idx, BOOL *stop) {
		return [subview isKindOfClass:UILabel.class];
	}];
	NSArray *labels = [self.subviews objectsAtIndexes:indexesOfLabels];
	for (UILabel *label in labels) {
		[label removeObserver:self forKeyPath:@"font"];
	}
}

- (void)didAddSubview:(UIView*)subview {
	[super didAddSubview:subview];
	if ([subview isKindOfClass:UIButton.class]) {
		UIButton *button = (UIButton*) subview;
		NSString *buttonTitle = button.titleLabel.text;
		if (buttonTitle.length == 0) {
			return;
		} else {
			[self addImageToButton:button];
		}
	} else if ([subview isKindOfClass:UILabel.class]) {
		[subview addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsLabel];
	}
}

- (void)addImageToButton:(UIButton*)button {
	NSString *buttonTitle = button.titleLabel.text;
	NSString *originalTitle = [self stringByRemovingFirstCharacterFromString:buttonTitle];
	UIImage *image = nil;
	switch ([buttonTitle characterAtIndex:0]) {
		case kTPWActionSheetActionAddress:
			image = [UIImage imageNamed:@"ActionIconAddress"];
			break;
		case kTPWActionSheetActionCopy:
			image = [UIImage imageNamed:@"ActionIconCopy"];
			break;
		case kTPWActionSheetActionEmail:
			image = [UIImage imageNamed:@"ActionIconEmail"];
			break;
		case kTPWActionSheetActionGetFullVersion:
			image = [UIImage imageNamed:@"ActionIconGetFullVersion"];
			break;
		case kTPWActionSheetActionHide:
			image = [UIImage imageNamed:@"ActionIconHide"];
			break;
		case kTPWActionSheetActionPhone:
			image = [UIImage imageNamed:@"ActionIconPhone"];
			break;
		case kTPWActionSheetActionReveal:
			image = [UIImage imageNamed:@"ActionIconReveal"];
			break;
		case kTPWActionSheetActionWeblink:
			image = [UIImage imageNamed:@"ActionIconWeblink"];
			break;
		default:
			break;
	}
	[self setImage:image andTitle:originalTitle onButton:button];
}

- (NSString*)stringByRemovingFirstCharacterFromString:(NSString*)input {
	if (input.length < 1) {
		return nil;
	} else {
		return [input substringFromIndex:1];
	}
}

- (void)setImage:(UIImage*)image andTitle:(NSString*)title onButton:(UIButton*)button {
	if (image != nil) {
		[button.titleLabel addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsButtonLabel];
		[button.imageView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsButtonImage];
	}
	[button setImage:image forState:UIControlStateNormal];
	[button setTitle:title forState:UIControlStateNormal];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if (context == &kTPWActionSheetObserverContextsButtonLabel) {
		UILabel *label = (UILabel *)object;
		[label removeObserver:self forKeyPath:@"frame"];
		[self layoutLabel:label];
		[label addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsButtonLabel];
	} else if (context == &kTPWActionSheetObserverContextsButtonImage) {
		UIImageView *imageView = (UIImageView *)object;
		[imageView removeObserver:self forKeyPath:@"frame"];
		[self layoutImageView:imageView];
		[imageView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsButtonImage];
	} else if (context == &kTPWActionSheetObserverContextsLabel) {
		UILabel *label = (UILabel *)object;
		[label removeObserver:self forKeyPath:@"font"];
		label.font = [UIFont tpwMonospaceFont];
		[label addObserver:self forKeyPath:@"font" options:NSKeyValueObservingOptionNew context:&kTPWActionSheetObserverContextsLabel];
	}
}

- (void)layoutLabel:(UILabel *)label {
	CGRect labelRect = label.frame;
	CGFloat labelWidth = label.superview.frame.size.width - kTPWActionSheetButtonPaddings - kTPWActionSheetImageViewWidthWithGap;
	labelRect.origin.x = kTPWActionSheetLabelOffset + floorf((labelWidth - label.frame.size.width) / 2.0);
	label.frame = labelRect;
}

- (void)layoutImageView:(UIImageView *)imageView {
	for (UIView *subview in self.subviews) {
		if ([subview isKindOfClass:UIButton.class]) {
			UIButton *button = (UIButton *)subview;
			if (imageView == button.imageView) {
				CGRect imageRect = imageView.frame;
				imageRect.origin.x = button.titleLabel.frame.origin.x - kTPWActionSheetImageViewOffset;
				imageView.frame = imageRect;
			}
		}
	}
}

#pragma mark - autodismissal

- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated {
	[super showFromRect:rect inView:view animated:animated];
	[self registerObserverForActionSheetDismissal];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
	[self unregisterObserverForActionSheetDismissal];
}

- (void)hideUsingCancel {
	[self dismissWithClickedButtonIndex:self.cancelButtonIndex animated:NO];
}

- (void)registerObserverForActionSheetDismissal {
	//hide action sheet on the following events:
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter addObserver:self selector:@selector(hideUsingCancel) name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter addObserver:self selector:@selector(hideUsingCancel) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)unregisterObserverForActionSheetDismissal {
	//hide action sheet on the following events:
	NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
	[notificationCenter removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

@end
