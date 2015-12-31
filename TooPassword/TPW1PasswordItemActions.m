//
//  TPW1PasswordItemActions.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 03.02.13.
//
//

#import "TPW1PasswordItemActions.h"
#import "TPWClipboard.h"
#import "TPWDateFormatter.h"
#import "TPWiOSVersions.h"
#import "TPWActionSheet.h"

NSTextCheckingTypes const kTPWItemActionDataDetectorTypes = NSTextCheckingTypeAddress|NSTextCheckingTypeLink|NSTextCheckingTypePhoneNumber;

NSString *const kTPWActionLinkUrlSchemeForMail = @"mailto";
NSString *const kTPWActionLinkUrlSchemeForHttp = @"http";
NSString *const kTPWActionLinkUrlSchemeForHttps = @"https";

NSString *const kTPWActionUrlPrefixForPhone = @"tel:";
NSString *const kTPWActionUrlPrefixForMaps = @"http://maps.apple.com/?q=";

NSString *const kTPWActionGetFullVersionSiteUrl = @"http://bit.ly/tooPassword";

@implementation TPW1PasswordItemActions

- (id)initWithActionsForText:(NSString*)text {
	return [self initWithActionsForText:text dataDetectorTypes:kTPWItemActionDataDetectorTypes];
}

- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes {
	if (self = [super init]) {
		self.text = text;
		if (text != nil && detectorTypes != 0) {
			NSError *error = nil;
			NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:detectorTypes error:&error];
			NSAssert(error == nil, @"error during initialization of NSDataDetector: %@", error);
			self.dataDetectorMatches = [detector matchesInString:text options:0 range:NSMakeRange(0, text.length)];
		}
	}
	return self;
}

- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes onReveal:(TPWActionSheetButtonPressedBlock)revealFeedback {
	if (self = [self initWithActionsForText:text dataDetectorTypes:detectorTypes]) {
		self.pressedRevealButtonFeedback = revealFeedback;
	}
	return self;
}

- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes onHide:(TPWActionSheetButtonPressedBlock)hideFeedback {
	if (self = [self initWithActionsForText:text dataDetectorTypes:detectorTypes]) {
		self.pressedHideButtonFeedback = hideFeedback;
	}
	return self;
}

#pragma mark - creating the action sheet

- (UIActionSheet*)actionSheetWithDelegate:(id<UIActionSheetDelegate>)delegate {
	NSString *title = (self.showsTextInActionSheet) ? self.text : nil;
	
	TPWActionSheet *actionSheet = [[TPWActionSheet alloc] initWithTitle:title delegate:delegate cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
	
	//first fixed button (index 0)
#ifndef FREE_VERSION
	NSString *copyButtonTitle = [self stringForButtonOfType:kTPWActionSheetActionCopy withTitle:NSLocalizedString(@"ui.details.actionsheet.copy", @"copy button in detail action sheet")];
	[actionSheet addButtonWithTitle:copyButtonTitle];
#else
	NSString *getFullVersionTitle = [self stringForButtonOfType:kTPWActionSheetActionGetFullVersion withTitle:NSLocalizedString(@"ui.details.actionsheet.getfullversion", @"get full version button in detail action sheet")];
	[actionSheet addButtonWithTitle:getFullVersionTitle];
#endif
	
	//optional second fixed button (index 1)
	if ([self hasRevealAction]) {
		NSString *revealButtonTitle = [self stringForButtonOfType:kTPWActionSheetActionReveal withTitle:NSLocalizedString(@"ui.details.actionsheet.reveal", @"reveal button in detail action sheet")];
		[actionSheet addButtonWithTitle:revealButtonTitle];
	} else if ([self hasHideAction]) {
		NSString *hideButtonTitle = [self stringForButtonOfType:kTPWActionSheetActionHide withTitle:NSLocalizedString(@"ui.details.actionsheet.hide", @"hide button in detail action sheet")];
		[actionSheet addButtonWithTitle:hideButtonTitle];
	}
	
	NSUInteger numberOfButtons = [self numberOfActionSheetButtonsWithoutContextSpecificButtons];
	
	//context-specific buttons
#ifndef FREE_VERSION
	for (NSTextCheckingResult *match in self.dataDetectorMatches) {
		NSString *buttonTitle;
		switch (match.resultType) {
			case NSTextCheckingTypeAddress:
				buttonTitle = [self addressButtonTitleForMatch:match];
				break;
			case NSTextCheckingTypeLink:
				buttonTitle = [self linkButtonTitleForMatch:match];
				break;
			case NSTextCheckingTypePhoneNumber:
				buttonTitle = [self phoneNumberButtonTitleForMatch:match];
				break;
			default:
				buttonTitle = nil;
				break;
		}
		if (buttonTitle != nil) {
			[actionSheet addButtonWithTitle:buttonTitle];
			numberOfButtons++;
		}
	}
#endif
	
	//cancel button
	NSString *cancelButtonTitle = [self stringForButtonOfType:kTPWActionSheetActionUndefined withTitle:NSLocalizedString(@"ui.common.cancel", @"cancel")];
	[actionSheet addButtonWithTitle:cancelButtonTitle];
	actionSheet.cancelButtonIndex = numberOfButtons;
	
	return actionSheet;
}

- (NSString*)stringForButtonOfType:(TPWActionSheetActions)action withTitle:(NSString*)title {
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"8.0"]) {
		return title;
	} else {
		return [NSString stringWithFormat:@"%c%@", action, title];
	}
}

- (NSString*)addressButtonTitleForMatch:(NSTextCheckingResult*)match {
	NSString *addressString = [self.text substringWithRange:match.range];
	if (addressString == nil) {
		return nil;
	} else if (![[UIApplication sharedApplication] canOpenURL:[self addressActionUrlForMatch:match]]) {
		return nil; //not supported on this device
	} else {
		return [self stringForButtonOfType:kTPWActionSheetActionAddress withTitle:addressString];
	}
}

- (NSString*)linkButtonTitleForMatch:(NSTextCheckingResult*)match {
	NSURL *url = match.URL;
	if (![[UIApplication sharedApplication] canOpenURL:[self linkActionUrlForMatch:match]]) {
		return nil; //not supported on this device
	} else if ([url.scheme isEqualToString:kTPWActionLinkUrlSchemeForMail]) {
		return [self stringForButtonOfType:kTPWActionSheetActionEmail withTitle:url.resourceSpecifier];
	} else if ([url.scheme isEqualToString:kTPWActionLinkUrlSchemeForHttp] || [url.scheme isEqualToString:kTPWActionLinkUrlSchemeForHttps]) {
		NSString *urlStr = (url.path.length > 1) ? [url.host stringByAppendingString:url.path] : url.host;
		return [self stringForButtonOfType:kTPWActionSheetActionWeblink withTitle:urlStr];
	} else {
		return nil;
	}
}

- (NSString*)phoneNumberButtonTitleForMatch:(NSTextCheckingResult*)match {
	if (![[UIApplication sharedApplication] canOpenURL:[self phoneActionUrlForMatch:match]]) {
		return nil; //not supported on this device
	} else {
		NSString *phoneNumber = match.phoneNumber;
		return [self stringForButtonOfType:kTPWActionSheetActionPhone withTitle:phoneNumber];
	}
}

#pragma mark - action urls

- (NSURL*)addressActionUrlForMatch:(NSTextCheckingResult*)match {
	NSString *addressString = [[self.text substringWithRange:match.range] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	return [NSURL URLWithString:[kTPWActionUrlPrefixForMaps stringByAppendingString:addressString]];
}

- (NSURL*)linkActionUrlForMatch:(NSTextCheckingResult*)match {
	return [match URL];
}

- (NSURL*)phoneActionUrlForMatch:(NSTextCheckingResult*)match {
	NSString *phoneNumber = [match phoneNumber];
	return [NSURL URLWithString:[kTPWActionUrlPrefixForPhone stringByAppendingString:phoneNumber]];
}

#pragma mark - invoking actions

- (BOOL)hasRevealAction {
	return (self.pressedRevealButtonFeedback != nil);
}

- (BOOL)hasHideAction {
	return (self.pressedHideButtonFeedback != nil);
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
#ifndef FREE_VERSION
		[self performCopyAction];
#else
		[self performGetFullVersionAction];
#endif
	} else if ([self hasRevealAction] && buttonIndex == 1) {
		[self performRevealAction];
	} else if ([self hasHideAction] && buttonIndex == 1) {
		[self performHideAction];
	} else if (buttonIndex < actionSheet.cancelButtonIndex) {
		NSInteger matchIndex = buttonIndex - [self numberOfActionSheetButtonsWithoutContextSpecificButtons];
		NSTextCheckingResult *match = self.dataDetectorMatches[matchIndex];
		switch (match.resultType) {
			case NSTextCheckingTypeAddress:
				[self performAddressActionForMatch:match];
				break;
			case NSTextCheckingTypeLink:
				[self performLinkActionForMatch:match];
				break;
			case NSTextCheckingTypePhoneNumber:
				[self performPhoneNumberActionForMatch:match];
				break;
			default:
				break;
		}
	}
}

- (NSUInteger)numberOfActionSheetButtonsWithoutContextSpecificButtons {
	return (![self hasRevealAction] && ![self hasHideAction])
		? 1		//only copy button [free: get full version button]
		: 2;	//copy and reveal/hide button
}

- (void)performCopyAction {
	[[TPWClipboard sharedClipboard] copyToClipboard:self.text];
}

- (void)performGetFullVersionAction {
	NSURL *url = [NSURL URLWithString:kTPWActionGetFullVersionSiteUrl];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)performRevealAction {
	if (self.pressedRevealButtonFeedback) {
		self.pressedRevealButtonFeedback();
	}
}

- (void)performHideAction {
	if (self.pressedHideButtonFeedback) {
		self.pressedHideButtonFeedback();
	}
}

- (void)performAddressActionForMatch:(NSTextCheckingResult*)match {
	NSURL *url = [self addressActionUrlForMatch:match];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)performLinkActionForMatch:(NSTextCheckingResult*)match {
	NSURL *url = [self linkActionUrlForMatch:match];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

- (void)performPhoneNumberActionForMatch:(NSTextCheckingResult*)match {
	NSURL *url = [self phoneActionUrlForMatch:match];
	if ([[UIApplication sharedApplication] canOpenURL:url]) {
		[[UIApplication sharedApplication] openURL:url];
	}
}

@end
