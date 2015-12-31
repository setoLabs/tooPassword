//
//  TPWAddressFormatter.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import "TPWAddressFormatter.h"

NSString *const kTPWAddressFormatterCountryCodeJsonKey = @"countryCode";
NSString *const kTPWAddressFormatterFormatJsonKey = @"format";
NSString *const kTPWDefaultCountryCode = @"US";

@implementation TPWAddressFormatter

- (NSString*)formatAddressWithComponents:(NSDictionary*)addressComponents forCountryCode:(NSString*)countryCode {
	TPWAddressFormat *formatToUse = self.addressFormatsByCountryCode[countryCode.uppercaseString];
	
	NSString *countryCodeForCurrentLocale = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
	if (formatToUse == nil) {
		DLog(@"country code %@ not found. try fallback to %@", countryCode.uppercaseString, countryCodeForCurrentLocale);
		formatToUse = self.addressFormatsByCountryCode[countryCodeForCurrentLocale];
	}
	
	if (formatToUse == nil) {
		DLog(@"country code %@ not found. fallback to %@", countryCodeForCurrentLocale, kTPWDefaultCountryCode);
		formatToUse = self.addressFormatsByCountryCode[kTPWDefaultCountryCode];
	}
	
	BOOL printCountry = ![countryCodeForCurrentLocale isEqualToString:countryCode.uppercaseString];
	
	return [formatToUse formatAddressComponents:addressComponents printDelimiterBefore:NO printCountry:printCountry];
}

#pragma mark - initialization

- (id)init {
	if (self = [super init]) {
		//load json
		NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"AddressFormats" ofType:@"json"];
		NSData *jsonData = [NSData dataWithContentsOfFile:jsonFilePath];
		NSError *error;
		NSArray *jsonDicts = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		if (error != nil) {
			DLog(@"could not parse json file at path %@", jsonFilePath);
			return nil;
		}
		
		//parse
		NSMutableDictionary *formatDict = [NSMutableDictionary dictionaryWithCapacity:jsonDicts.count];
		for (NSDictionary *jsonDict in jsonDicts) {
			NSString *countryCode = jsonDict[kTPWAddressFormatterCountryCodeJsonKey];
			NSDictionary *formatJsonDict = jsonDict[kTPWAddressFormatterFormatJsonKey];
			TPWAddressFormat *format = [[TPWAddressFormat alloc] initWithJsonDictionary:formatJsonDict];
			formatDict[countryCode] = format;
		}
		self.addressFormatsByCountryCode = formatDict;
	}
	return self;
}

#pragma mark - instance

+ (TPWAddressFormatter*)sharedInstance {
	static dispatch_once_t onceToken;
	static TPWAddressFormatter *instance;
	dispatch_once(&onceToken, ^{
		instance = [[TPWAddressFormatter alloc] init];
	});
	return instance;
}

@end
