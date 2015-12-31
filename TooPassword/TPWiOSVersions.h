//
//  TPWiOSVersions.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 04.02.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWiOSVersions : NSObject

+ (BOOL)isGreaterThanOrEqualToVersion:(NSString *)version;
+ (BOOL)isLessThanVersion:(NSString *)version;

@end
