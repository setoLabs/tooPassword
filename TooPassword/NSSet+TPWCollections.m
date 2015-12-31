//
//  NSSet+TPWCollections.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.04.13.
//
//

#import <libkern/OSAtomic.h>

#import "NSSet+TPWCollections.h"

@implementation NSSet (TPWCollections)

- (NSSet*)subsetConstrainedToSize:(int32_t)maximumNumberOfItems {
	__volatile __block int32_t counter = 0;
	return [self objectsWithOptions:NSEnumerationConcurrent passingTest:^BOOL(id obj, BOOL *stop) {
		if (OSAtomicCompareAndSwapInt(maximumNumberOfItems, maximumNumberOfItems, &counter)) {
			*stop = YES;
		}
		OSAtomicIncrement32(&counter);
		return YES;
	}];
}

@end
