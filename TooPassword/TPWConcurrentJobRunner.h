//
//  TPWConcurrentJobRunner.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import <Foundation/Foundation.h>

extern int32_t kTPWConcurrentJobRunnerDefaultBulkSize;

@interface TPWConcurrentJobRunner : NSObject
@property (nonatomic, strong) NSMutableSet *pendingJobs;

- (id)initWithJobs:(NSSet*)pendingJobs;
- (void)runJobsConcurrentlyInBulksWithSize:(int32_t)bulkSize;
- (void)cancel;

@end
