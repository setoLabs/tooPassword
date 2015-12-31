//
//  TPWLoadContentsMetadataJob.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWAbstractImportJob.h"

typedef void(^TPWLoadContentsMetadataCallback)(BOOL success, NSError *error);


@protocol TPWContentsMetadataImporter <NSObject>
- (void)loadMetadataForContentsFileWithCallback:(TPWLoadContentsMetadataCallback)callback;
@end

@interface TPWLoadContentsMetadataJob : TPWAbstractImportJob

@property (nonatomic, weak) NSObject<TPWContentsMetadataImporter> *metadataImporter;

- (id)initWithCallback:(TPWImportJobCallback)callback metadataImporter:(NSObject<TPWContentsMetadataImporter>*)importer;

@end
