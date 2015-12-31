//
//  TPWWebDAVPropfinder.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 01.12.13.
//
//

#import <Foundation/Foundation.h>

#import "TPWWebDAVResponse.h"

/**
 @param responses Array of TPWWebDAVResponse instances
 @param error Error or nil
 */
typedef void(^TPWWebDAVPropfindResponseParserCallback)(NSArray *responses, NSError *error);

@interface TPWWebDAVPropfindResponseParser : NSObject

- (instancetype)initWithXMLData:(NSData*)xmlData encoding:(NSStringEncoding)encoding;

- (void)parseResponses:(TPWWebDAVPropfindResponseParserCallback)callback;
- (void)cancelParsing;

@end
