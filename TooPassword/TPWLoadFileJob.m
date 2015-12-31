//
//  TPWLoadFileJob.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWLoadFileJob.h"

@interface TPWLoadFileJob ()
@property (nonatomic, copy) TPWLoadFileProgressCallback progressCallback;
@end

@implementation TPWLoadFileJob

- (id)initWithCallback:(TPWImportJobCallback)callback progressCallback:(TPWLoadFileProgressCallback)progressCallback src:(NSString*)src dst:(NSString*)dst fileImporter:(NSObject<TPWFileImporter>*)importer retryOnFail:(BOOL)retry {
	if (self = [super initWithCallback:callback retryOnFail:retry]) {
		self.progressCallback = progressCallback;
		self.srcPath = src;
		self.dstPath = dst;
		self.fileImporter = importer;
	}
	return self;
}

- (id)initWithCallback:(TPWImportJobCallback)callback progressCallback:(TPWLoadFileProgressCallback)progressCallback src:(NSString*)src dst:(NSString*)dst fileImporter:(NSObject<TPWFileImporter>*)importer {
	return [self initWithCallback:callback progressCallback:progressCallback src:src dst:dst fileImporter:importer retryOnFail:YES];
}

- (void)startJob {
	[self.fileImporter loadFile:self.srcPath intoPath:self.dstPath onCompletion:^(BOOL success, NSError *error) {
		if (self.callback) {
			self.callback(self, success);
		}
	} onProgress:^(CGFloat progress) {
		if (self.progressCallback) {
			self.progressCallback(progress);
		}
	}];
}

- (void)cancelJob {
	// not implemented
}

- (NSString*)description {
	return [NSString stringWithFormat:@"TPWLoadFileJob {srcFile=%@, dstFile=%@}", self.srcPath.lastPathComponent, self.dstPath.lastPathComponent];
}

@end
