//
//  TPWiOSVersions.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 04.02.13.
//
//

#import "TPWiOSVersions.h"

@implementation TPWiOSVersions

+ (BOOL)isGreaterThanOrEqualToVersion:(NSString *)version {
	return [[UIDevice currentDevice].systemVersion compare:version options:NSNumericSearch] != NSOrderedAscending;
}

+ (BOOL)isLessThanVersion:(NSString *)version {
	return [[UIDevice currentDevice].systemVersion compare:version options:NSNumericSearch] == NSOrderedAscending;
}

@end
