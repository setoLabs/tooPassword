//
//  TPWAbstractImporter.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import <Foundation/Foundation.h>
#import "TPWConstants.h"
#import "TPWImportableFileChecking.h"

typedef void(^TPWImportCallback)(BOOL success, NSError *error);
typedef void(^TPWImportProgressCallback)(CGFloat progress);

@interface TPWAbstractImporter : NSObject <TPWImportableFileChecking>

@property (nonatomic, strong) NSString *sourcePath;
@property (nonatomic, copy) TPWImportCallback callback;
@property (nonatomic, copy) TPWImportProgressCallback progressCallback;
@property (nonatomic, assign) dispatch_queue_t importerQueue;

- (void)importKeychainAtPath:(NSString *)sourcePath onCompletion:(TPWImportCallback)callback onProgress:(TPWImportProgressCallback)progressCallback;
- (void)cancel;
- (void)callbackWithSuccess;
- (void)callbackWithError:(NSError *)error;
- (void)callbackWithProgress:(CGFloat)progress;

@end
