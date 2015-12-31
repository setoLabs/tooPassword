//
//  NSString+TPWExtensions.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 01.12.13.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kTPWStringExtensionsPathSeperator;

@interface NSString (TPWExtensions)

- (NSString*)URLStringByAppendingPathComponent:(NSString*)pathComponent;
+ (NSString*)haystackUsingHay:(NSString*)hay, ... NS_REQUIRES_NIL_TERMINATION;

@end
