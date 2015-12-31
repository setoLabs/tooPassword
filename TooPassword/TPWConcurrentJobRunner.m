//
//  TPWConcurrentJobRunner.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import <libkern/OSAtomic.h>

#import "TPWAbstractImportJob.h"
#import "NSSet+TPWCollections.h"

#import "TPWConcurrentJobRunner.h"

int32_t kTPWConcurrentJobRunnerDefaultBulkSize = 100;

@interface TPWConcurrentJobRunner ()
@property (nonatomic, strong) NSCondition *jobsLoadedCondition;
@property (nonatomic, strong) NSMutableSet *currentBulk;
@property (nonatomic, assign) BOOL canceled;
@end

@implementation TPWConcurrentJobRunner

- (id)initWithJobs:(NSSet*)pendingJobs {
	if (self = [super init]) {
		self.pendingJobs = [pendingJobs mutableCopy];
		self.jobsLoadedCondition = [[NSCondition alloc] init];
		self.canceled = NO;
	}
	return self;
}

- (void)runJobsConcurrentlyInBulksWithSize:(int32_t)bulkSize {
	while (self.pendingJobs.count > 0 && !self.canceled) {
		DLog(@"loading bulk: start");
		self.currentBulk = [[self.pendingJobs subsetConstrainedToSize:bulkSize] mutableCopy];
		[self runCurrentBulkConcurrently];
		DLog(@"loading bulk: end");
	}
}

- (void)cancel {
	self.canceled = YES;
	for (TPWAbstractImportJob *job in [self.currentBulk copy]) {
		[job cancelJob];
	}
}

#pragma mark - private stuff

- (void)runCurrentBulkConcurrently {
	[self.jobsLoadedCondition lock];
	
	// start all jobs
	for (TPWAbstractImportJob *job in [self.currentBulk copy]) {
		[self startJob:job];
	}
		
	// wait until all jobs are done
	while (self.currentBulk.count > 0) {
		[self.jobsLoadedCondition wait];
	}
	
	[self.jobsLoadedCondition unlock];
}

- (void)startJob:(TPWAbstractImportJob*)job {
	DLog(@"Start: %@", job);
	TPWImportJobCallback originalCallback = job.callback;
	job.callback = ^(TPWAbstractImportJob *job, BOOL success) {
		originalCallback(job, success);
		if (success || job.retryCounter > kTPWImportJobMaxRetryCount) {
			[self.pendingJobs removeObject:job];
		} else {
			DLog(@"Retrying (%tu/%tu) failed job: %@", job.retryCounter, kTPWImportJobMaxRetryCount, job);
			job.retryCounter++;
		}
		DLog(@"End: %@", job);
		[self.currentBulk removeObject:job];
		[self.jobsLoadedCondition signal];
	};
	[job startJob];
}

@end
