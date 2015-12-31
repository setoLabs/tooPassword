//
//  TPWAddressFormat.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import "TPWAddressFormat.h"

NSString *const kTPWAddressFormatComponentsJsonKey = @"components";
NSString *const kTPWAddressFormatComponentTypeJsonKey = @"type";
NSString *const kTPWAddressFormatComponentTypeComponent = @"component";
NSString *const kTPWAddressFormatComponentTypeFormat = @"format";

@implementation TPWAddressFormat

- (id)initWithJsonDictionary:(NSDictionary *)jsonDict {
	if (self = [super initWithJsonDictionary:jsonDict]) {
		NSArray *compJsonDicts = jsonDict[kTPWAddressFormatComponentsJsonKey];
		NSMutableArray *comps = [NSMutableArray arrayWithCapacity:compJsonDicts.count];
		for (NSDictionary *compJsonDict in compJsonDicts) {
			NSString *compType = compJsonDict[kTPWAddressFormatComponentTypeJsonKey];
			if ([compType isEqualToString:kTPWAddressFormatComponentTypeComponent]) {
				TPWAddressComponent *comp = [[TPWAddressComponent alloc] initWithJsonDictionary:compJsonDict];
				[comps addObject:comp];
			} else if ([compType isEqualToString:kTPWAddressFormatComponentTypeFormat]) {
				TPWAddressFormat *comp = [[TPWAddressFormat alloc] initWithJsonDictionary:compJsonDict];
				[comps addObject:comp];
			}
		}
		self.components = comps;
	}
	return self;
}

- (NSString*)description {
	NSMutableString *description = [NSMutableString string];
	for (TPWAddressComponent *comp in self.components) {
		[description appendFormat:@"%@%@", (comp.delimiterBefore) ? : @"", comp.description];
	}
	return description;
}

- (NSString*)formatAddressComponents:(NSDictionary*)componentDict printDelimiterBefore:(BOOL)printDelimiterBefore printCountry:(BOOL)printCountry {
	NSMutableString *addressString = [NSMutableString string];
	
	//print delimiterBefore
	if (self.delimiterBefore && printDelimiterBefore) {
		[addressString appendString:self.delimiterBefore];
	}
	
	//print prefix
	if (self.prefix) {
		[addressString appendString:self.prefix];
	}
	
	//print components
	NSMutableString *componentsString = [NSMutableString string];
	for (TPWAddressComponent *comp in self.components) {
		BOOL shouldPrintDelimiter = componentsString.length != 0;
		NSString *compString = [comp formatAddressComponents:componentDict printDelimiterBefore:shouldPrintDelimiter printCountry:printCountry];
		if (compString != nil) {
			[componentsString appendString:compString];
		}
	}
	[addressString appendString:componentsString];
	
	//print suffix
	if (self.suffix) {
		[addressString appendString:self.suffix];
	}
	return addressString;
}

@end
