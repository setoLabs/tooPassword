//
//  NSDate+RFCFormats.m
//  TooPassword
//
//  Created by Tobias Hagemann on 27/10/13.
//
//

#import "NSDate+RFCFormats.h"

@implementation NSDate (RFCFormats)

+ (NSDateFormatter *)rfc822Formatter {
	static NSDateFormatter *formatter;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		formatter = [[NSDateFormatter alloc] init];
		NSLocale *enUS = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
		[formatter setLocale:enUS];
		[formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
	});
	return formatter;
}

+ (NSDate *)dateFromRFC822:(NSString *)date {
	return [[NSDate rfc822Formatter] dateFromString:date];
}

- (NSString *)rfc822String {
	return [[NSDate rfc822Formatter] stringFromDate:self];
}

@end
