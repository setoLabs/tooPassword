//
//  TPWLoadFileJob.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 16.04.13.
//
//

#import "TPWAbstractImportJob.h"

typedef void(^TPWLoadFileCallback)(BOOL success, NSError *error);
typedef void(^TPWLoadFileProgressCallback)(CGFloat progress);


@protocol TPWFileImporter <NSObject>
- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback;
@end

	
@interface TPWLoadFileJob : TPWAbstractImportJob

@property (nonatomic, strong) NSString *srcPath;
@property (nonatomic, strong) NSString *dstPath;
@property (nonatomic, weak) NSObject<TPWFileImporter> *fileImporter;

- (id)initWithCallback:(TPWImportJobCallback)callback progressCallback:(TPWLoadFileProgressCallback)progressCallback src:(NSString*)src dst:(NSString*)dst fileImporter:(NSObject<TPWFileImporter>*)importer retryOnFail:(BOOL)retry;
- (id)initWithCallback:(TPWImportJobCallback)callback progressCallback:(TPWLoadFileProgressCallback)progressCallback src:(NSString*)src dst:(NSString*)dst fileImporter:(NSObject<TPWFileImporter>*)importer;

@end
