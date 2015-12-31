//
//  TPWAddressFormatter.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWAddressFormat.h"

@interface TPWAddressFormatter : NSObject

@property (nonatomic, strong) NSDictionary *addressFormatsByCountryCode;

- (NSString*)formatAddressWithComponents:(NSDictionary*)addressComponents forCountryCode:(NSString*)countryCode;

+ (TPWAddressFormatter*)sharedInstance;

@end
