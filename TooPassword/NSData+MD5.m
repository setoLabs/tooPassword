//
//  NSData+MD5.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 19.01.13.
//
//

#import "NSData+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSData (MD5)

- (NSData*)md5 {
	unsigned char buffer[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], (CC_LONG)[self length], buffer);
	return [NSData dataWithBytes:buffer length:CC_MD5_DIGEST_LENGTH];
}

@end
