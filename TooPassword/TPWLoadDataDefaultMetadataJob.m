//
//  TPWLoadDataDefaultMetadataJob.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWLoadDataDefaultMetadataJob.h"

@implementation TPWLoadDataDefaultMetadataJob

- (id)initWithCallback:(TPWImportJobCallback)callback metadataImporter:(NSObject<TPWDataDefaultMetadataImporter> *)importer {
	if (self = [super initWithCallback:callback]) {
		self.metadataImporter = importer;
	}
	return self;
}

- (void)startJob {
	[self.metadataImporter loadMetadataForDataDefaultDirectoryWithCallback:^(BOOL success, NSError *error) {
		if (self.callback) {
			self.callback(self, success);
		}
	}];
}

- (void)cancelJob {
	// not implemented
}

@end
