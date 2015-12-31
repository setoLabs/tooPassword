//
//  TPWDBRestClient.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/24/13.
//
//

#import <Foundation/Foundation.h>
#import <DropboxSDK/DropboxSDK.h>

typedef void(^TPWDBRestClientLoadFileCallback)(BOOL success, NSError *error);
typedef void(^TPWDBRestClientLoadFileProgressCallback)(CGFloat progress);
typedef void(^TPWDBRestClientMetadataCallback)(DBMetadata *metadata, NSError *error);

@interface TPWDBRestClient : NSObject

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWDBRestClientLoadFileCallback)callback onProgress:(TPWDBRestClientLoadFileProgressCallback)progressCallback;
- (void)loadMetadata:(NSString *)sourcePath onCompletion:(TPWDBRestClientMetadataCallback)callback;
- (void)cancelAll;
- (void)cancelLoadOfFile:(NSString*)sourcePath;

@end
