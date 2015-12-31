//
//  NSSet+TPWCollections.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.04.13.
//
//

#import <Foundation/Foundation.h>

@interface NSSet (TPWCollections)

- (NSSet*)subsetConstrainedToSize:(int32_t)maximumNumberOfItems;

@end
