//
//  TPWAbstractAgileKeychainImporter.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWAbstractImporter.h"

#import "TPWLoadFileJob.h"
#import "TPWLoadDataDefaultMetadataJob.h"
#import "TPWLoadContentsMetadataJob.h"

typedef enum {
	TPWAbstractAgileKeychainImporterErrorLoadingMetadata,
	TPWAbstractAgileKeychainImporterErrorParsingContents,
	TPWAbstractAgileKeychainImporterErrorLoadingPayload
} TPWAbstractAgileKeychainImporterError;

extern NSString *const kTPWAgileKeychainImporterErrorDomain;

@interface TPWAbstractAgileKeychainImporter : TPWAbstractImporter <TPWFileImporter, TPWDataDefaultMetadataImporter, TPWContentsMetadataImporter>

@property (nonatomic, strong) NSDictionary *localPayloadRevisions;
@property (nonatomic, strong) NSDictionary *remotePayloadRevisions;
@property (nonatomic, strong) NSDate *keychainModificationDate;
@property (nonatomic, readonly) NSString *destinationTempKeychainPath;
@property (nonatomic, readonly) NSString *importerSource;
@property (nonatomic, readonly) NSString *sourceDataDefaultPath;


@end
