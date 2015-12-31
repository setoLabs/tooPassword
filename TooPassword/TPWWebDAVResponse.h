//
//  TPWWebDAVResponse.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 28.11.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWWebDAVResponse : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong, readonly) NSString *href;
@property (nonatomic, strong, readonly) NSString *status;
@property (nonatomic, strong, readonly) NSDate *lastModified;
@property (nonatomic, assign, readonly, getter = isCollection) BOOL collection;

- (instancetype)initWithParserRootDelegate:(id<NSXMLParserDelegate>)rootDelegate;

@end
