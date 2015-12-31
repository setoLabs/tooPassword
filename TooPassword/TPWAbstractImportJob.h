//
//  TPWImportJob.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import <Foundation/Foundation.h>

extern NSUInteger const kTPWImportJobMaxRetryCount;

@class TPWAbstractImportJob;

typedef void(^TPWImportJobCallback)(TPWAbstractImportJob *job, BOOL loadSuccess);

@interface TPWAbstractImportJob : NSObject

@property (nonatomic, copy) TPWImportJobCallback callback;
@property (nonatomic, assign) NSUInteger retryCounter;

- (void)startJob;
- (void)cancelJob;

- (id)initWithCallback:(TPWImportJobCallback)callback;
- (id)initWithCallback:(TPWImportJobCallback)callback retryOnFail:(BOOL)retry;

@end
