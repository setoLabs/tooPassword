//
//  TPWLoadDataDefaultMetadataJob.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWAbstractImportJob.h"

typedef void(^TPWLoadDataDefaultMetadataCallback)(BOOL success, NSError *error);


@protocol TPWDataDefaultMetadataImporter <NSObject>
- (void)loadMetadataForDataDefaultDirectoryWithCallback:(TPWLoadDataDefaultMetadataCallback)callback;
@end

@interface TPWLoadDataDefaultMetadataJob : TPWAbstractImportJob

@property (nonatomic, weak) NSObject<TPWDataDefaultMetadataImporter> *metadataImporter;

- (id)initWithCallback:(TPWImportJobCallback)callback metadataImporter:(NSObject<TPWDataDefaultMetadataImporter>*)importer;

@end
