//
//  TPWAddressFormatterTests.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import "TPWAddressFormatterTests.h"
#import "TPWAddressFormatter.h"
#import "TPWAddressFormat.h"

@implementation TPWAddressFormatterTests

- (void)testAddressFormatsJsonParsing {
	NSDictionary *formats = [[TPWAddressFormatter sharedInstance] addressFormatsByCountryCode];
	XCTAssertTrue(formats.count > 0, @"expected at least one address format");
	XCTAssertTrue(formats[@"DE"] != nil, @"expected german address format");
	DLog(@"address formats: %@", formats);
}

- (void)testGermanAddress {
	NSDictionary *formats = [[TPWAddressFormatter sharedInstance] addressFormatsByCountryCode];
	XCTAssertTrue(formats[@"DE"] != nil, @"expected german address format");
	TPWAddressFormat *germanFormat = formats[@"DE"];

	NSDictionary *addressComps1 = @{@"address1": @"Buntspechtweg 47", @"zip": @"53123", @"city": @"Bonn"};
	NSString *address1 = [germanFormat formatAddressComponents:addressComps1 printDelimiterBefore:NO printCountry:NO];
	XCTAssertTrue([address1 isEqualToString:@"Buntspechtweg 47, 53123 Bonn"], @"wrong address format");
	
	NSDictionary *addressComps2 = @{@"address2": @"Buntspechtweg 47", @"zip": @"53123", @"city": @"Bonn"};
	NSString *address2 = [germanFormat formatAddressComponents:addressComps2 printDelimiterBefore:NO printCountry:NO];
	XCTAssertTrue([address2 isEqualToString:@"Buntspechtweg 47, 53123 Bonn"], @"wrong address format");
	
	NSDictionary *addressComps3 = @{@"address2": @"Buntspechtweg 47", @"city": @"Bonn"};
	NSString *address3 = [germanFormat formatAddressComponents:addressComps3 printDelimiterBefore:NO printCountry:NO];
	XCTAssertTrue([address3 isEqualToString:@"Buntspechtweg 47, Bonn"], @"wrong address format");

}

@end
