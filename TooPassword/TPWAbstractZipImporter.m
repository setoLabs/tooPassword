//
//  TPWAbstractZipImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 7/4/13.
//
//

#import "TPWFileUtil.h"
#import "TPWConcurrentJobRunner.h"

#import "TPWAbstractZipImporter.h"
#import "TPWiTunesAgileKeychainImporter.h"

NSString *const kTPWZipImporterErrorDomain = @"TPWZipImporterErrorDomain";

@interface TPWAbstractZipImporter ()
@property (nonatomic, strong) TPWConcurrentJobRunner *jobRunner;
@property (nonatomic, strong) NSString *zipFilePath;
@end

@implementation TPWAbstractZipImporter

- (void)importKeychainAtPath:(NSString *)sourcePath onCompletion:(TPWImportCallback)callback onProgress:(TPWImportProgressCallback)progressCallback {
	[super importKeychainAtPath:sourcePath onCompletion:callback onProgress:progressCallback];
	[self prepareFolders];
	
	dispatch_async(self.importerQueue, ^{
		[self import];
	});
}

- (void)prepareFolders {
	NSString *zipTmpPath = self.destinationTempZipPath;
	[[NSFileManager defaultManager] removeItemAtPath:zipTmpPath error:NULL];
	[[NSFileManager defaultManager] createDirectoryAtPath:zipTmpPath withIntermediateDirectories:YES attributes:nil error:NULL];
}

- (void)cancel {
	[self.jobRunner cancel];
}

- (void)import {
	NSAssert([NSThread currentThread] != [NSThread mainThread], @"Should only be invoked in background thread.");
	
	// Step 1: load zip file
	if (![self loadZipFile]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWZipImporterErrorDomain code:TPWAbstractZipImporterErrorLoadingFile userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 2: extract zip file
	if (![self extractZipFile]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWZipImporterErrorDomain code:TPWAbstractZipImporterErrorUnzippingFile userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 3: choose keychain path from zip content
	NSString *keychainPath = [self chooseKeychainPathFromTempZipPath];
	if (!keychainPath) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWZipImporterErrorDomain code:TPWAbstractZipImporterErrorNoKeychainFound userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 4: move keychain to documents directory
	NSString *filename = [keychainPath lastPathComponent];
	NSString *destinationPath = [[TPWFileUtil documentsPath] stringByAppendingPathComponent:filename];
	if (![self moveKeychainAtPath:keychainPath toPath:destinationPath]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWZipImporterErrorDomain code:TPWAbstractZipImporterErrorMovingKeychain userInfo:nil];
		[self callbackWithError:error];
		return;
	}
	
	// Step 5: import keychain
	TPWAbstractImporter *keychainImporter = [self suitableImporterForPath:destinationPath];
	[keychainImporter importKeychainAtPath:destinationPath onCompletion:^(BOOL success, NSError *error) {
		if (success) {
			// Step 6: cleanup
			[self cleanupAfterSuccessfulImport];
			
			// finish
			[self callbackWithSuccess];
		} else {
			[self callbackWithError:error];
		}
	} onProgress:^(CGFloat progress) {
		[self callbackWithProgress:progress];
	}];
}

- (BOOL)loadZipFile {
	NSString *filename = [self.sourcePath lastPathComponent];
	NSString *destinationPath = self.destinationTempZipPath;
	
	__block BOOL zipFileLoaded = NO;
	NSString *zipFileSrcPath = self.sourcePath;
	NSString *zipFileDstPath = [destinationPath stringByAppendingPathComponent:filename];
	TPWAbstractImportJob *loadZipFileJob = [[TPWLoadFileJob alloc] initWithCallback:^(TPWAbstractImportJob *job, BOOL loadSuccess) {
		zipFileLoaded = loadSuccess;
	} progressCallback:^(CGFloat progress) {
		[self callbackWithProgress:progress];
	} src:zipFileSrcPath dst:zipFileDstPath fileImporter:self];
	self.zipFilePath = zipFileDstPath;
	
	NSSet *jobs = [NSSet setWithObject:loadZipFileJob];
	self.jobRunner = [[TPWConcurrentJobRunner alloc] initWithJobs:jobs];
	[self.jobRunner runJobsConcurrentlyInBulksWithSize:1];
	
	return zipFileLoaded;
}

- (BOOL)extractZipFile {
	NSString *sourcePath = self.zipFilePath;
	NSString *destinationPath = self.destinationTempZipPath;
	BOOL success = [SSZipArchive unzipFileAtPath:sourcePath toDestination:destinationPath];
	return success;
}

- (NSString *)chooseKeychainPathFromTempZipPath {
	NSError *error = nil;
	NSString *tmpZipPath = self.destinationTempZipPath;
	NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmpZipPath error:&error];
	if (error) {
		return nil;
	}
	
	__weak TPWAbstractZipImporter *weakSelf = self;
	__block NSString *importableKeychainFilename = nil;
	[directoryContents enumerateObjectsUsingBlock:^(NSString *filename, NSUInteger idx, BOOL *stop) {
		NSUInteger indexOfSuitableImporter = [weakSelf.suitableImporters indexOfObjectPassingTest:^BOOL(TPWAbstractImporter *importer, NSUInteger idx, BOOL *stop) {
			return [importer canImportFileAtPath:filename];
		}];
		if (indexOfSuitableImporter != NSNotFound) {
			importableKeychainFilename = filename;
			*stop = YES;
		}
	}];
	
	if (importableKeychainFilename) {
		NSString *keychainPath = [tmpZipPath stringByAppendingPathComponent:importableKeychainFilename];
		return keychainPath;
	}
	return nil;
}

- (BOOL)moveKeychainAtPath:(NSString *)sourcePath toPath:(NSString *)destinationPath {
	[[NSFileManager defaultManager] removeItemAtPath:destinationPath error:NULL];
	BOOL success = [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destinationPath error:NULL];
	return success;
}

- (TPWAbstractImporter *)suitableImporterForPath:(NSString *)path {
	for (TPWAbstractImporter *importer in self.suitableImporters) {
		if ([importer canImportFileAtPath:path]) {
			return importer;
		}
	}
	return nil;
}

- (NSArray *)suitableImporters {
	TPWiTunesAgileKeychainImporter *agileKeychainImporter = [[TPWiTunesAgileKeychainImporter alloc] init];
	return @[agileKeychainImporter];
}

- (void)cleanupAfterSuccessfulImport {
	NSString *zipFilePath = self.zipFilePath;
	NSString *zipTmpPath = self.destinationTempZipPath;
	
	[[NSFileManager defaultManager] removeItemAtPath:zipFilePath error:NULL];
	[[NSFileManager defaultManager] removeItemAtPath:zipTmpPath error:NULL];
}

#pragma mark -
#pragma mark TPWFileImporter

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSAssert(false, @"Overwrite this method.");
}

#pragma mark -
#pragma mark Accessors

- (NSString *)destinationTempZipPath {
	static NSString *destinationTempKeychainPath = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		destinationTempKeychainPath = [TPWFileUtil privateDocumentsPath];
		destinationTempKeychainPath = [destinationTempKeychainPath stringByAppendingPathComponent:kTPWPrivateZipTempDirectory];
	});
	
	return destinationTempKeychainPath;
}

#pragma mark -
#pragma mark TPWImportableFileChecking

- (BOOL)canImportFileAtPath:(NSString *)path {
	return [path.pathExtension isEqualToString:kTPWZipFileExtension];
}

@end
