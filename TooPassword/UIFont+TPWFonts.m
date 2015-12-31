//
//  UIFont+TPWFonts.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 13.05.13.
//
//

#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"

@implementation UIFont (TPWFonts)

+ (UIFont *)tpwDefaultFont {
	static UIFont *font;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)] ) {
//			font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
//		} else {
			CGFloat fontSize = [UIFont labelFontSize];
			font = [UIFont systemFontOfSize:fontSize];
//		}
	});
	return font;
}

+ (UIFont *)tpwMonospaceFont {
	static UIFont *font;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)] ) {
//			UIFontDescriptor *preferredFont = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleBody];
//			CGFloat fontSize = [preferredFont pointSize];
//			font = [UIFont fontWithName:@"Courier" size:fontSize];
//		} else {
			CGFloat fontSize = [UIFont labelFontSize];
			font = [UIFont fontWithName:@"Courier" size:fontSize];
//		}
	});
	return font;
}

+ (UIFont *)tpwHeadlineFont {
	static UIFont *font;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)] ) {
//			font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
//		} else {
			font = [UIFont boldSystemFontOfSize:20.0];
//		}
	});
	return font;
}

+ (UIFont *)tpwSubheadlineFont {
	static UIFont *font;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)] ) {
//			font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
//		} else {
			if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"]) {
				font = [UIFont systemFontOfSize:17.0];
			} else {
				font = [UIFont boldSystemFontOfSize:17.0];
			}
//		}
	});
	return font;
}

+ (UIFont *)tpwFootnoteFont {
	static UIFont *font;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
//		if ([UIFont respondsToSelector:@selector(preferredFontForTextStyle:)] ) {
//			font = [UIFont preferredFontForTextStyle:UIFontTextStyleFootnote];
//		} else {
			font = [UIFont systemFontOfSize:15.0];
//		}
	});
	return font;
}

@end
