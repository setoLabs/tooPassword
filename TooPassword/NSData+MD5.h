//
//  NSData+MD5.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 19.01.13.
//
//

#import <Foundation/Foundation.h>

@interface NSData (MD5)

/**
 \return 16 byte NSData representing the md5 hash of the data.
 */
- (NSData*)md5;

@end
