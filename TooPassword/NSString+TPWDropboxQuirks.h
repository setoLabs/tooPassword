//
//  NSString+TPWDropboxQuirks.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.10.13.
//
//

#import <Foundation/Foundation.h>

@interface NSString (TPWDropboxQuirks)

- (NSString *)normalizedDropboxPathForUseAsDictKey;

@end
