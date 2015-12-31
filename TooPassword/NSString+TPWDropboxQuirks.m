//
//  NSString+TPWDropboxQuirks.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.10.13.
//
//

#import "NSString+TPWDropboxQuirks.h"

@implementation NSString (TPWDropboxQuirks)

- (NSString *)normalizedDropboxPathForUseAsDictKey {
	return [[self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString];
}

@end
