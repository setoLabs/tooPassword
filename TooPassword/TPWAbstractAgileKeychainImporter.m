//
//  TPWAbstractAgileKeychainImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import <libkern/OSAtomic.h>

#import "TPWFileUtil.h"
#import "NSSet+TPWCollections.h"
#import "NSString+TPWExtensions.h"
#import "TPWConcurrentJobRunner.h"
#import "TPWAgileKeychainMetadataWriter.h"
#import "TPWAgileKeychainMetadataReader.h"

#import "TPWAbstractAgileKeychainImporter.h"

NSString *const kTPWAgileKeychainImporterErrorDomain = @"TPWAgileKeychainImporterErrorDomain";

@interface TPWAbstractAgileKeychainImporter ()
@property (nonatomic, strong) TPWConcurrentJobRunner *jobRunner;
@end

@implementation TPWAbstractAgileKeychainImporter

- (void)importKeychainAtPath:(NSString *)sourcePath onCompletion:(TPWImportCallback)callback onProgress:(TPWImportProgressCallback)progressCallback {
	[super importKeychainAtPath:sourcePath onCompletion:callback onProgress:progressCallback];
	[self prepareFolders];
	
	dispatch_async(self.importerQueue, ^{
		[self import];
	});
}

- (void)prepareFolders {
	NSString *keychainPath = [TPWFileUtil keychainPath];
	NSString *keychainTmpPath = [TPWFileUtil keychainTmpPath];
	[[NSFileManager defaultManager] createDirectoryAtPath:keychainPath withIntermediateDirectories:YES attributes:nil error:nil];
	[[NSFileManager defaultManager] removeItemAtPath:keychainTmpPath error:NULL];
	[[NSFileManager defaultManager] createDirectoryAtPath:keychainTmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)cancel {
	[self.jobRunner cancel];
}

- (void)import {
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Should only be invoked in background thread.");
	
	// Step 1: load metadata
	if (![self loadMetadata]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWAgileKeychainImporterErrorDomain code:TPWAbstractAgileKeychainImporterErrorLoadingMetadata userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 2: parse contents.js
	NSSet *payloadJobs = [self payloadJobsByParsingContents];
	if (!payloadJobs) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWAgileKeychainImporterErrorDomain code:TPWAbstractAgileKeychainImporterErrorParsingContents userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 3: load payload
	if (![self loadPayload:payloadJobs]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWAgileKeychainImporterErrorDomain code:TPWAbstractAgileKeychainImporterErrorLoadingPayload userInfo:nil];
		[self callbackWithError:error];
	}
	
	// Step 4: determine unchanged files
	NSString *tmpKeychainPath = [TPWFileUtil keychainTmpPath];
	NSString *keychainPath = [TPWFileUtil keychainPath];
	NSMutableSet *unchangedFiles = [NSMutableSet setWithCapacity:self.remotePayloadRevisions.count];
	for (NSString *filename in self.remotePayloadRevisions.allKeys) {
		NSString *newRevisionNumber = self.remotePayloadRevisions[filename];
		NSString *oldRevisionNumber = self.localPayloadRevisions[filename];
		if ([newRevisionNumber isEqualToString:oldRevisionNumber]) {
			[unchangedFiles addObject:filename];
		}
	}
	
	// Step 5: retain unchanged files
	NSError *error;
	for (NSString *filename in unchangedFiles) {
		NSString *oldPath = [keychainPath stringByAppendingPathComponent:filename];
		NSString *newPath = [tmpKeychainPath stringByAppendingPathComponent:filename];
		if (![[NSFileManager defaultManager] fileExistsAtPath:newPath]) {
			[[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
		}
		if (error) {
			[self callbackWithError:error];
			return;
		}
	}
	
	// Step 6: delete old keychain and move tmp to dst
	[[NSFileManager defaultManager] removeItemAtPath:keychainPath error:NULL]; // we don't care
	[[NSFileManager defaultManager] moveItemAtPath:tmpKeychainPath toPath:keychainPath error:&error];
	if (error) {
		[self callbackWithError:error];
		return;
	}
	
	// Step 7: determine payload revisions
	NSSet *keys = [self.remotePayloadRevisions keysOfEntriesWithOptions:NSEnumerationConcurrent passingTest:^BOOL(NSString *filename, NSString *revisionNumber, BOOL *stop) {
		NSString *path = [keychainPath stringByAppendingPathComponent:filename];
		return [[NSFileManager defaultManager] fileExistsAtPath:path];
	}];
	NSDictionary *payloadRevisions = [self.remotePayloadRevisions dictionaryWithValuesForKeys:keys.allObjects];
	
	// Step 8: save new metadata
	TPWAgileKeychainMetadataWriter *writer = [[TPWAgileKeychainMetadataWriter alloc] init];
	writer.modificationDate = self.keychainModificationDate;
	writer.path = self.sourcePath;
	writer.source = self.importerSource;
	writer.revisionNumbers = payloadRevisions;
	[writer writeMetadataToFile];
	
	// Step 9: cleanup
	[self cleanupAfterSuccessfulImport];
	
	// finish
	[self callbackWithSuccess];
}

- (BOOL)loadMetadata {
	NSString *sourceDataDefaultPath = self.sourceDataDefaultPath;
	NSString *destinationTempKeychainPath = self.destinationTempKeychainPath;

	// Load contents.js
	__block BOOL contentsFileLoaded = NO;
	NSString *contentsFileSrcPath = [sourceDataDefaultPath URLStringByAppendingPathComponent:kTPWContentsFileName];
	NSString *contentsFileDstPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPWContentsFileName];
	TPWAbstractImportJob *contentsJob = [[TPWLoadFileJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		contentsFileLoaded = loadSuccess;
	} progressCallback:nil src:contentsFileSrcPath dst:contentsFileDstPath fileImporter:self];
	
	// Load encryptionKeys.js
	__block BOOL keysJsonFileLoaded = NO;
	NSString *keysJsonFileSrcPath = [sourceDataDefaultPath URLStringByAppendingPathComponent:kTPWEncryptionKeysFileName];
	NSString *keysJsonFileDstPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPWEncryptionKeysFileName];
	TPWAbstractImportJob *keysJsonJob = [[TPWLoadFileJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		keysJsonFileLoaded = loadSuccess;
	} progressCallback:nil src:keysJsonFileSrcPath dst:keysJsonFileDstPath fileImporter:self];
	
	// Load 1Password.keys
	__block BOOL keysPlistFileLoaded = NO;
	NSString *keysPlistFileSrcPath = [sourceDataDefaultPath URLStringByAppendingPathComponent:kTPW1PasswordKeysFileName];
	NSString *keysPlistFileDstPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPW1PasswordKeysFileName];
	TPWAbstractImportJob *keysPlistJob = [[TPWLoadFileJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		keysPlistFileLoaded = loadSuccess;
	} progressCallback:nil src:keysPlistFileSrcPath dst:keysPlistFileDstPath fileImporter:self];
	
	// Load .password.hint
	__block BOOL hintFileLoaded = NO;
	NSString *hintFileSrcPath = [sourceDataDefaultPath URLStringByAppendingPathComponent:kTPWPasswordHintFileName];
	NSString *hintFileDstPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPWPasswordHintFileName];
	TPWAbstractImportJob *hintJob = [[TPWLoadFileJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		hintFileLoaded = loadSuccess;
	} progressCallback:nil src:hintFileSrcPath dst:hintFileDstPath fileImporter:self retryOnFail:NO];
	
	// Load last modification date
	__block BOOL lastModificationDateLoaded = NO;
	TPWAbstractImportJob *dataDefaultMetadataJob = [[TPWLoadContentsMetadataJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		lastModificationDateLoaded = loadSuccess;
	} metadataImporter:self];
	
	// Load new revision numbers
	__block BOOL newRevisionNumbersLoaded = NO;
	TPWAbstractImportJob *contentsMetadataJob = [[TPWLoadDataDefaultMetadataJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		newRevisionNumbersLoaded = loadSuccess;
	} metadataImporter:self];
	
	// Load hashcodes of old keychain payload
	TPWMetadataReader *reader = [TPWMetadataReader reader];
	self.localPayloadRevisions = reader.revisionNumbers;
	
	// Load metadata first (because metadata might become unavailable after loading the corresponding source file)
	NSSet *metadataJobs = [NSSet setWithObjects:dataDefaultMetadataJob, contentsMetadataJob, nil];
	self.jobRunner = [[TPWConcurrentJobRunner alloc] initWithJobs:metadataJobs];
	[self.jobRunner runJobsConcurrentlyInBulksWithSize:kTPWConcurrentJobRunnerDefaultBulkSize];
	
	// Load metadata failed
	if (!lastModificationDateLoaded || !newRevisionNumbersLoaded) {
		return NO;
	}
	
	// Load files after finishing metadataJobs
	NSSet *fileJobs = [NSSet setWithObjects:contentsJob, keysJsonJob, keysPlistJob, hintJob, nil];
	self.jobRunner = [[TPWConcurrentJobRunner alloc] initWithJobs:fileJobs];
	[self.jobRunner runJobsConcurrentlyInBulksWithSize:kTPWConcurrentJobRunnerDefaultBulkSize];
	
	return contentsFileLoaded && (keysJsonFileLoaded || keysPlistFileLoaded);
}

- (NSSet*)payloadJobsByParsingContents {
	NSString *contentsFilePath = [self.destinationTempKeychainPath stringByAppendingPathComponent:kTPWContentsFileName];
	NSData *contentsFileData = [NSData dataWithContentsOfFile:contentsFilePath];
	NSError *error;
	NSArray *contents = [NSJSONSerialization JSONObjectWithData:contentsFileData options:0 error:&error];
	if (error) {
		return nil;
	}
	
	NSMutableSet *result = [NSMutableSet setWithCapacity:contents.count];
	for (NSArray *content in contents) {
		TPWLoadFileJob *job = [self payloadJobByParsingContent:content];
		if (job) {
			[result addObject:job];
		}
	}
	
	return result;
}

- (TPWLoadFileJob*)payloadJobByParsingContent:(NSArray*)singleContentMetadata {
	NSString *fileBaseName = [singleContentMetadata firstObject];
	NSString *filename = [fileBaseName stringByAppendingPathExtension:kTPW1PasswordFileExtension];
	NSString *hiddenFlag = [singleContentMetadata lastObject];
	NSString *oldRevision = self.localPayloadRevisions[filename];
	NSString *newRevision = self.remotePayloadRevisions[filename];
	if ([hiddenFlag isEqualToString:@"N"] && [self shouldLoadFileWithNewRevision:newRevision oldRevision:oldRevision]) {
		NSString *srcPath = [self.sourceDataDefaultPath stringByAppendingPathComponent:filename];
		NSString *dstPath = [self.destinationTempKeychainPath stringByAppendingPathComponent:filename];
		return [[TPWLoadFileJob alloc] initWithCallback:nil progressCallback:nil src:srcPath dst:dstPath fileImporter:self];
	} else {
		return nil;
	}
}

- (BOOL)shouldLoadFileWithNewRevision:(NSString*)newRevision oldRevision:(NSString*)oldRevision {
	return newRevision.length == 0 || ![newRevision isEqualToString:oldRevision];
}

- (BOOL)loadPayload:(NSSet*)loadJobs {
	self.jobRunner = [[TPWConcurrentJobRunner alloc] initWithJobs:loadJobs];
	
	// initialize vars for progress callback
	__volatile __block int32_t jobsDone = 0;
	CGFloat jobsTotal = [loadJobs count] * 1.0;
	
	// configure success callback for all jobs:
	__block BOOL success = YES;
	[loadJobs makeObjectsPerformSelector:@selector(setCallback:) withObject:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		if (loadSuccess) {
			OSAtomicIncrement32(&jobsDone);
			CGFloat progress = jobsDone / jobsTotal;
			[self callbackWithProgress:progress];
		} else if (job.retryCounter > kTPWImportJobMaxRetryCount) {
			success = NO;
			[self.jobRunner cancel];
		}
	}];
	
	// start loading in bulks of 100 jobs
	DLog(@"loading payload: start");
	[self.jobRunner runJobsConcurrentlyInBulksWithSize:kTPWConcurrentJobRunnerDefaultBulkSize];
	DLog(@"loading payload: end");
	
	return success;
}

- (void)cleanupAfterSuccessfulImport {
	NSAssert(false, @"Overwrite this method.");
}

#pragma mark -
#pragma mark TPWDataDefaultMetadataImporter, TPWContentsMetadataImporter, TPWFileImporter

- (void)loadMetadataForDataDefaultDirectoryWithCallback:(TPWLoadFileCallback)callback {
	NSAssert(false, @"Overwrite this method.");
}

- (void)loadMetadataForContentsFileWithCallback:(TPWLoadFileCallback)callback {
	NSAssert(false, @"Overwrite this method.");
}

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSAssert(false, @"Overwrite this method.");
}

#pragma mark -
#pragma mark Accessors

- (NSString *)destinationTempKeychainPath {
	static NSString *destinationTempKeychainPath = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		destinationTempKeychainPath = [TPWFileUtil privateDocumentsPath];
		destinationTempKeychainPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPWPrivateKeychainTempDirectory];
	});
	
	return destinationTempKeychainPath;
}

- (NSString*)importerSource {
	NSAssert(false, @"overwrite this method");
	return nil;
}

- (NSString *)sourceDataDefaultPath {
	NSString *dataPath = [self.sourcePath URLStringByAppendingPathComponent:kTPWKeychainDataDirectory];
	return [dataPath URLStringByAppendingPathComponent:kTPWKeychainDataDefaultDirectory];
}

#pragma mark -
#pragma mark TPWImportableFileChecking

- (BOOL)canImportFileAtPath:(NSString *)path {
	return [path.pathExtension isEqualToString:kTPWAgileKeychainFileExtension];
}

@end
