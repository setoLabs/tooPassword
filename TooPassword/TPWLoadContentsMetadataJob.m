//
//  TPWLoadContentsMetadataJob.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWLoadContentsMetadataJob.h"

@implementation TPWLoadContentsMetadataJob

- (id)initWithCallback:(TPWImportJobCallback)callback metadataImporter:(NSObject<TPWContentsMetadataImporter> *)importer {
	if (self = [super initWithCallback:callback]) {
		self.metadataImporter = importer;
	}
	return self;
}

- (void)startJob {
	[self.metadataImporter loadMetadataForContentsFileWithCallback:^(BOOL success, NSError *error) {
		if (self.callback) {
			self.callback(self, success);
		}
	}];
}

- (void)cancelJob {
	// not implemented
}

@end
