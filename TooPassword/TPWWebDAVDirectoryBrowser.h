//
//  TPWWebDAVDirectoryBrowser.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.11.13.
//
//

#import "TPWAbstractDirectoryBrowser.h"

typedef NS_ENUM(NSUInteger, TPWWebDAVDirectoryBrowserError) {
	TPWWebDAVDirectoryBrowserErrorInterrupted
};

extern NSString *const kTPWWebDAVDirectoryBrowserErrorDomain;

@interface TPWWebDAVDirectoryBrowser : TPWAbstractDirectoryBrowser

- (id)initWithWorkingDirectory:(NSString *)path username:(NSString*)username password:(NSString*)password;
- (id)initWithWorkingDirectory:(NSString *)path basePath:(NSString*)basePath username:(NSString*)username password:(NSString*)password;

@end
