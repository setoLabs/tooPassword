//
//  TPWImportJob.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWAbstractImportJob.h"

NSUInteger const kTPWImportJobMaxRetryCount = 3;

@implementation TPWAbstractImportJob

- (id)initWithCallback:(TPWImportJobCallback)callback {
	return [self initWithCallback:callback retryOnFail:YES];
}

- (id)initWithCallback:(TPWImportJobCallback)callback retryOnFail:(BOOL)retry {
	if (self = [super init]) {
		self.callback = callback;
		self.retryCounter = (retry) ? 0 : NSUIntegerMax;
	}
	return self;
}

- (void)startJob {
	NSAssert(false, @"overwrite this method");
}

- (void)cancelJob {
	if (self.callback) {
		self.callback(self, NO);
		self.callback = nil;
	}
}

@end
