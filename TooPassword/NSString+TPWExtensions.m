//
//  NSString+TPWExtensions.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 01.12.13.
//
//

#import "NSString+TPWExtensions.h"

NSString *const kTPWStringExtensionsPathSeperator = @"/";

@implementation NSString (TPWExtensions)

- (NSString*)URLStringByAppendingPathComponent:(NSString*)pathComponent {
	if ([self hasSuffix:kTPWStringExtensionsPathSeperator]) {
		return [self stringByAppendingString:pathComponent];
	} else {
		return [self stringByAppendingFormat:@"%@%@", kTPWStringExtensionsPathSeperator, pathComponent];
	}
}

+ (NSString*)haystackUsingHay:(NSString*)hay, ... {
	va_list args;
    va_start(args, hay);
	NSMutableString *haystack = [NSMutableString string];
	for (NSString *str = hay; str != nil; str = va_arg(args, NSString*)) {
		if (str.length > 0) {
			[haystack appendString:@" "];
			[haystack appendString:str];
		}
    }
    va_end(args);
	return haystack;
}

@end
