//
//  TPWAbstractZipImporter.h
//  TooPassword
//
//  Created by Tobias Hagemann on 7/4/13.
//
//

#import "SSZipArchive.h"

#import "TPWAbstractImporter.h"

#import "TPWLoadFileJob.h"

typedef enum {
	TPWAbstractZipImporterErrorLoadingFile,
	TPWAbstractZipImporterErrorUnzippingFile,
	TPWAbstractZipImporterErrorNoKeychainFound,
	TPWAbstractZipImporterErrorMovingKeychain
} TPWAbstractZipImporterError;

extern NSString *const kTPWZipImporterErrorDomain;

@interface TPWAbstractZipImporter : TPWAbstractImporter <TPWFileImporter, SSZipArchiveDelegate>

@property (nonatomic, readonly) NSString *destinationTempZipPath;

@end
