//
//  TPWWebDAVClient.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.11.13.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TPWWebDAVClientError) {
	TPWPooledAsyncHttpClientErrorConnectionFailed,
	TPWPooledAsyncHttpClientErrorNotFound,
	TPWPooledAsyncHttpClientErrorAuthFailed,
	TPWPooledAsyncHttpClientErrorOther,
	TPWPooledAsyncHttpClientErrorUnsupportedProtocol,
	TPWPooledAsyncHttpClientErrorInterrupted
};

extern NSString *const kTPWPooledAsyncHttpClientErrorHttpStatusCodeKey;
extern NSString *const kTPWPooledAsyncHttpClientErrorDomain;

#pragma mark -

@interface TPWPooledAsyncHttpClientResponse : NSObject
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *response;
@property (nonatomic, assign) NSStringEncoding responseEncoding;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, strong) NSString *responseDataPath;

/**
 @brief checks if response header contains dav key
 */
- (BOOL)isSupportingWebDAVProtocol;

@end

#pragma mark -

/**
 @param response Wrapper of NSHTTPURLResponse and NSData...
 @param error If request failed...
 */
typedef void(^TPWPooledAsyncHttpClientCompleted)(NSNumber *tag, TPWPooledAsyncHttpClientResponse *response, NSError *error);

/**
 @param newURL New url (you don't say)
 */
typedef void(^TPWPooledAsyncHttpClientRedirected)(NSNumber *tag, NSURL *newURL);

/**
 @param progress in percent
 */
typedef void(^TPWPooledAsyncHttpClientInProgress)(CGFloat progress);

#pragma mark -

@interface TPWPooledAsyncHttpClient : NSObject
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

/**
 @brief schedules the given request for execution. Request will be started FIFO with a certain maximum amount of simultanuous connections.
 @param request Request to schedule
 @param destinationPath If present, responseData will be saved to specified file (optional)
 @param callback Callback when request finishes or fails
 @return Tag for easier identification of the request
 */
- (NSNumber*)makeRequest:(NSURLRequest*)request downloadToPath:(NSString*)destinationPath onRedirect:(TPWPooledAsyncHttpClientRedirected)redirectCallback onCompletion:(TPWPooledAsyncHttpClientCompleted)completionCallback onProgress:(TPWPooledAsyncHttpClientInProgress)progressCallback;

/**
 @brief cancels/unschedules the request with the given tag, if such a tag is still present. Otherwise nothing will happen.
 @param tag Identifier of the request to be canceled
 */
- (void)cancelRequest:(NSNumber*)tag;

/**
 @brief cancels/unschedules all pending requests. No further callbacks will be invoked.
 */
- (void)cancelAllRequest;

@end
