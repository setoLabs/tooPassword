//
//  TPWAddressComponent.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kTPWAddressComponentFieldnameJsonKey;
extern NSString *const kTPWAddressComponentDelimiterBeforeJsonKey;
extern NSString *const kTPWAddressComponentPrefixJsonKey;
extern NSString *const kTPWAddressComponentSuffixJsonKey;

@interface TPWAddressComponent : NSObject

@property (nonatomic, strong) NSString *fieldname;
@property (nonatomic, strong) NSString *delimiterBefore;
@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *suffix;

- (id)initWithJsonDictionary:(NSDictionary*)jsonDict;

- (NSString*)formatAddressComponents:(NSDictionary*)componentDict printDelimiterBefore:(BOOL)printDelimiterBefore printCountry:(BOOL)printCountry;

@end
