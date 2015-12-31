//
//  TPW1PasswordFieldKeyUtil.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import "TPW1PasswordFieldKeyUtil.h"
#import "TPWDateFormatter.h"
#import "TPWAddressFormatter.h"

NSString *const kTPW1PasswordFieldLocalizationTable = @"LocalizableFieldKeys";

NSString *const kTPW1PasswordFieldKeyUtilDateComponentYearPostfix = @"_yy";
NSString *const kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix = @"_mm";
NSString *const kTPW1PasswordFieldKeyUtilDateComponentDayPostfix = @"_dd";

NSString *const kTPW1PasswordFieldKeyUtilAddressKey = @"address";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentAddress1 = @"address1";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentAddress2 = @"address2";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentState = @"state";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentZip = @"zip";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentCity = @"city";
NSString *const kTPW1PasswordFieldKeyUtilAddressComponentCountry = @"country";

NSString *const kTPW1PasswordFieldKeyUtilShortenedPostfix = @"#9";
NSString *const kTPW1PasswordFieldKeyUtilLocalPostfix = @"_local";

@implementation TPW1PasswordFieldKeyUtil

- (BOOL)shouldObfuscateValueForKey:(NSString*)key {
	static NSArray *fieldsToObfuscate;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		fieldsToObfuscate = @[@"password", @"password#9", @"disk_password", @"disk_password#9", @"pop_password", @"smtp_password", @"admin_console_password", @"admin_console_password#9", @"answer", @"answer#9", @"wireless_password", @"wireless_password#9", @"access_key", @"access_key#9", @"cvv", @"cvv#9", @"pin", @"pin#9", @"telephonePin"];
	});
	return [fieldsToObfuscate containsObject:key];
}

#pragma mark - tidying dicts

- (NSMutableDictionary*)shortenedTidyFieldDictionaryFromRawDictionary:(NSDictionary*)input {
	NSDictionary *tidyDict = [self tidyFieldDictionaryFromRawDictionary:input];
	NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:tidyDict.count];
	
	for (NSString *key in tidyDict.allKeys) {
		NSString *shortenedKey = [self shortenedKeyIfAvailableForKey:key];
		output[shortenedKey] = tidyDict[key];
	}
	
	return output;
}

- (NSMutableDictionary*)tidyFieldDictionaryFromRawDictionary:(NSDictionary*)input {
	NSArray *keysOfInterest = [self tidyFieldKeysFromRawDictionary:input];
	NSMutableDictionary *output = [NSMutableDictionary dictionaryWithCapacity:keysOfInterest.count];
	
	for (NSString *key in keysOfInterest) {
		if ([self isDateComponentKey:key]) {
			NSString *dateComponentBaseName = [self baseNameOfDateComponentKey:key];
			NSString *formattedDate = [self formattedDateWithDateComponentBaseName:dateComponentBaseName inDictionary:input];
			output[dateComponentBaseName] = formattedDate;
		} else if ([self isAddressComponentKey:key]) {
			NSString *localizedFormattedAddress = [self localizedAddressFromComponentsInDictionary:input];
			output[kTPW1PasswordFieldKeyUtilAddressKey] = localizedFormattedAddress;
		} else if ([self isLocalKey:key]) {
			NSString *keyBaseName = [self baseNameOfLocalKey:key];
			output[keyBaseName] = input[key];
		} else {
			//default: add object for key from input to output
			output[key] = input[key];
		}
	}
	
	return output;
}

- (NSArray*)tidyFieldKeysFromRawDictionary:(NSDictionary*)input {
	NSMutableArray *result  = [NSMutableArray arrayWithCapacity:input.count];
	NSMutableArray *processedKeys = [NSMutableArray arrayWithCapacity:input.count];
	for (NSString *key in input.allKeys) {
		if ([processedKeys containsObject:key]) {
			//skip already processed keys
		} else if ([self isDateComponentKey:key]) {
			//only add component basename to result, mark all related components as processed.
			NSString *dateComponentBaseName = [self baseNameOfDateComponentKey:key];
			NSArray *allRelatedComponentKeys = [self dateComponentKeysWithBaseName:dateComponentBaseName inDictionary:input];
			[processedKeys addObjectsFromArray:allRelatedComponentKeys];
			[result addObject:key]; //we want the key, not the basename, otherwise we can't identify the key as a date key later
		} else if ([self isAddressComponentKey:key]) {
			//only add component basename to result, mark all related components as processed.
			NSArray *allRelatedComponentKeys = [self addressComponentKeysInDictionary:input];
			[processedKeys addObjectsFromArray:allRelatedComponentKeys];
			[result addObject:key]; //we want the key, not the basename, otherwise we can't identify the key as a date key later
		} else {
			//default: if not empty: add key to result and mark as processed
			if (![self valueIsEmpty:input[key]]) {
				[result addObject:key];
			}
			[processedKeys addObject:key];
		}
	}
	return result;
}

- (BOOL)valueIsEmpty:(id)value {
	if (value == [NSNull null]) {
		return YES;
	} else if ([value isKindOfClass:NSString.class]) {
		return [(NSString*)value length] == 0;
	} else if ([value isKindOfClass:NSValue.class]) {
		return [[(NSValue*)value description] length] == 0;
	}
	return YES;
}

#pragma mark - date component processing

- (NSString*)formattedDateWithDateComponentBaseName:(NSString*)prefix inDictionary:(NSDictionary*)dictionary {
	NSString *dayCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix];
	NSDate *date = [self dateFromComponentsWithBaseName:prefix inDictionary:dictionary];
	if ([dictionary objectForKey:dayCompKey] == nil) {
		//no day component
		return [[TPWDateFormatter localizedDMDateFormatter] stringFromDate:date];
	} else {
		//all components
		return [[TPWDateFormatter localizedDMYDateFormatter] stringFromDate:date];
	}
}

- (NSDate*)dateFromComponentsWithBaseName:(NSString*)prefix inDictionary:(NSDictionary*)dictionary {
	NSString *yearCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentYearPostfix];
	NSString *monthCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix];
	NSString *dayCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix];
	NSInteger year = [self integerValueForKey:yearCompKey inDictionary:dictionary];
	NSInteger month = [self integerValueForKey:monthCompKey inDictionary:dictionary] ? : 1;
	NSInteger day = [self integerValueForKey:dayCompKey inDictionary:dictionary] ? : 1;
	
	//in 1pw everything is saved in gregorean format.
	NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *dateComps = [[NSDateComponents alloc] init];
	[dateComps setCalendar:gregorianCalendar];
	[dateComps setYear:year];
	[dateComps setMonth:month];
	[dateComps setDay:day];
	
	//1pw doesn't know other calendars. we do NOT transfer the date to the local calendar of the user.
	return [gregorianCalendar dateFromComponents:dateComps];
}

- (NSInteger)integerValueForKey:(NSString*)key inDictionary:(NSDictionary*)dictionary {
	id value = [dictionary valueForKey:key]; //should be a NSString or NSValue
	if ([value respondsToSelector:@selector(integerValue)]) {
		return [value integerValue];
	} else {
		return 0;
	}
}

- (NSArray*)dateComponentKeysWithBaseName:(NSString*)prefix inDictionary:(NSDictionary*)dictionary {
	NSString *yearCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentYearPostfix];
	NSString *monthCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix];
	NSString *dayCompKey = [prefix stringByAppendingString:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix];
	
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
	if ([dictionary objectForKey:yearCompKey] != nil) {
		[result addObject:yearCompKey];
	}
	if ([dictionary objectForKey:monthCompKey] != nil) {
		[result addObject:monthCompKey];
	}
	if ([dictionary objectForKey:dayCompKey] != nil) {
		[result addObject:dayCompKey];
	}
	return result;
}

- (BOOL)isDateComponentKey:(NSString*)key {
	return [key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentYearPostfix]
		|| [key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix]
		|| [key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix];
}

- (NSString*)baseNameOfDateComponentKey:(NSString*)key {
	if ([key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentYearPostfix]) {
		NSRange suffixRange = [key rangeOfString:kTPW1PasswordFieldKeyUtilDateComponentYearPostfix];
		return [key substringToIndex:suffixRange.location];
	} else if ([key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix]) {
		NSRange suffixRange = [key rangeOfString:kTPW1PasswordFieldKeyUtilDateComponentMonthPostfix];
		return [key substringToIndex:suffixRange.location];
	} else if ([key hasSuffix:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix]) {
		NSRange suffixRange = [key rangeOfString:kTPW1PasswordFieldKeyUtilDateComponentDayPostfix];
		return [key substringToIndex:suffixRange.location];
	} else {
		return nil;
	}
}

#pragma mark - address field processing

- (BOOL)isAddressComponentKey:(NSString*)key {
	return [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentAddress1]
		|| [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentAddress2]
		|| [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentZip]
		|| [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentCity]
		|| [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentState]
		|| [key isEqualToString:kTPW1PasswordFieldKeyUtilAddressComponentCountry];
}

- (NSString*)localizedAddressFromComponentsInDictionary:(NSDictionary*)dictionary {
	NSString *country = dictionary[kTPW1PasswordFieldKeyUtilAddressComponentCountry];
	
	return [[TPWAddressFormatter sharedInstance] formatAddressWithComponents:dictionary forCountryCode:country];
}

- (NSArray*)addressComponentKeysInDictionary:(NSDictionary*)dictionary {
	NSMutableArray *result = [NSMutableArray arrayWithCapacity:3];
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentAddress1] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentAddress1];
	}
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentAddress2] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentAddress2];
	}
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentZip] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentZip];
	}
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentCity] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentCity];
	}
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentState] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentState];
	}
	if ([dictionary objectForKey:kTPW1PasswordFieldKeyUtilAddressComponentCountry] != nil) {
		[result addObject:kTPW1PasswordFieldKeyUtilAddressComponentCountry];
	}
	return result;
}

#pragma mark - local phone processing

- (BOOL)isLocalKey:(NSString*)key {
	return [key hasSuffix:kTPW1PasswordFieldKeyUtilLocalPostfix];
}

- (NSString*)baseNameOfLocalKey:(NSString*)key {
	NSRange suffixRange = [key rangeOfString:kTPW1PasswordFieldKeyUtilLocalPostfix];
	if (suffixRange.location == NSNotFound) {
		return key;
	} else {
		return [key substringToIndex:suffixRange.location];
	}
}

#pragma mark - shortened key processing

- (NSString*)shortenedKeyIfAvailableForKey:(NSString*)key {
	static NSString *const nonExistingKey = @"#NONEXISTING#";
	NSString *shortenedKey = [key stringByAppendingString:kTPW1PasswordFieldKeyUtilShortenedPostfix];
	if ([[[NSBundle mainBundle] localizedStringForKey:shortenedKey value:nonExistingKey table:kTPW1PasswordFieldLocalizationTable] isEqualToString:nonExistingKey]) {
		return key;
	} else {
		return shortenedKey;
	}
}

#pragma mark - singleton

+ (TPW1PasswordFieldKeyUtil*)sharedInstance {
	static TPW1PasswordFieldKeyUtil *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[TPW1PasswordFieldKeyUtil alloc] init];
	});
	return instance;
}

@end
