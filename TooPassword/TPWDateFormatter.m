//
//  TPWDateFormatter.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import "TPWDateFormatter.h"

@implementation TPWDateFormatter

- (id)init {
	if (self = [super init]) {
		self.dateFormatters = [NSMutableDictionary dictionary];
	}
	return self;
}

- (NSDateFormatter*)dateFormatterWithFormat:(NSString*)format {
	NSDateFormatter *formatter = self.dateFormatters[format];
	if (formatter == nil) {
		formatter = [[NSDateFormatter alloc] init];
		formatter.dateFormat = format;
		formatter.locale = [NSLocale currentLocale];
		self.dateFormatters[format] = formatter;
	}
	return formatter;
}

#pragma mark - 

+ (TPWDateFormatter*)sharedInstance {
	static TPWDateFormatter *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[TPWDateFormatter alloc] init];
	});
	return instance;
}

+ (NSDateFormatter*)dateFormatterWithFormat:(NSString*)format {
	return [[TPWDateFormatter sharedInstance] dateFormatterWithFormat:format];
}

+ (NSDateFormatter*)localizedDMYDateFormatter {
	NSString *localizedFormat = [NSDateFormatter dateFormatFromTemplate:@"dMMMMY" options:0 locale:[NSLocale currentLocale]];
	return [[TPWDateFormatter sharedInstance] dateFormatterWithFormat:localizedFormat];
}

+ (NSDateFormatter*)localizedDMDateFormatter {
	NSString *localizedFormat = [NSDateFormatter dateFormatFromTemplate:@"MMMMY" options:0 locale:[NSLocale currentLocale]];
	return [[TPWDateFormatter sharedInstance] dateFormatterWithFormat:localizedFormat];
}

@end
