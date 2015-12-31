//
//  TPWAddressComponent.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import "TPWAddressComponent.h"

NSString *const kTPWAddressComponentFieldnameJsonKey = @"fieldname";
NSString *const kTPWAddressComponentDelimiterBeforeJsonKey = @"delimiterBefore";
NSString *const kTPWAddressComponentPrefixJsonKey = @"prefix";
NSString *const kTPWAddressComponentSuffixJsonKey = @"suffix";
NSString *const kTPWAddressComponentCountryKey = @"country";

@implementation TPWAddressComponent

- (id)initWithJsonDictionary:(NSDictionary *)jsonDict {
	if (self = [super init]) {
		self.fieldname = jsonDict[kTPWAddressComponentFieldnameJsonKey];
		self.delimiterBefore = jsonDict[kTPWAddressComponentDelimiterBeforeJsonKey];
		self.prefix = jsonDict[kTPWAddressComponentPrefixJsonKey];
		self.suffix = jsonDict[kTPWAddressComponentSuffixJsonKey];
	}
	return self;
}

- (NSString*)description {
	return [NSString stringWithFormat:@"%@%@%@",
				(self.prefix) ? : @"",
				self.fieldname,
				(self.suffix) ? : @""];
}

- (NSString*)formatAddressComponents:(NSDictionary*)componentDict printDelimiterBefore:(BOOL)printDelimiterBefore printCountry:(BOOL)printCountry {
	NSString *componentValue = componentDict[self.fieldname];
	
	//check, if there actually is sth to format
	if (componentValue == nil || componentValue.length == 0 || ([self.fieldname isEqualToString:kTPWAddressComponentCountryKey] && !printCountry)) {
		return nil;
	}
	
	NSMutableString *addressString = [NSMutableString string];
	
	//print delimiterBefore
	if (self.delimiterBefore && printDelimiterBefore) {
		[addressString appendString:self.delimiterBefore];
	}
	
	//print prefix
	if (self.prefix) {
		[addressString appendString:self.prefix];
	}
	
	if ([self.fieldname isEqualToString:kTPWAddressComponentCountryKey]) {
		NSString *displayNameForCountryCode = [self displayNameForCountryCode:componentValue];
		NSString *countryNameOrCountryCode = displayNameForCountryCode ? : componentValue;
		[addressString appendString:countryNameOrCountryCode];
	} else {
		[addressString appendString:componentValue];
	}
	
	//print suffix
	if (self.suffix) {
		[addressString appendString:self.suffix];
	}
	return addressString;
}

- (NSString*)displayNameForCountryCode:(NSString*)countryCode {
	return [[NSLocale currentLocale] displayNameForKey:NSLocaleCountryCode value:countryCode];
}

@end
