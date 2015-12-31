//
//  TPWAbstractSyncChecker.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.05.13.
//
//

#import "TPWAbstractSyncChecker.h"
#import "TPWDropboxSyncChecker.h"
#import "TPWiTunesSyncChecker.h"
#import "TPWWebDAVSyncChecker.h"

@implementation TPWAbstractSyncChecker

+ (TPWAbstractSyncChecker*)syncChecker {
	TPWMetadataReader *reader = [TPWMetadataReader reader];
	TPWAbstractSyncChecker *checker = [TPWAbstractSyncChecker syncCheckerForSource:reader.source];
	checker.reader = reader;
	return checker;
}

+ (TPWAbstractSyncChecker*)syncCheckerForSource:(NSString*)source {
	for (TPWAbstractSyncChecker *checker in [TPWAbstractSyncChecker syncCheckers]) {
		if ([checker canCheckSync:source]) {
			return checker;
		}
	}
	return nil;
}

+ (NSArray*)syncCheckers {
	static NSArray *syncCheckers;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		TPWAbstractSyncChecker *dropboxSyncChecker = [[TPWDropboxSyncChecker alloc] init];
		TPWAbstractSyncChecker *iTunesSyncChecker = [[TPWiTunesSyncChecker alloc] init];
		TPWAbstractSyncChecker *webDAVSyncChecker = [[TPWWebDAVSyncChecker alloc] init];
		syncCheckers = @[dropboxSyncChecker, iTunesSyncChecker, webDAVSyncChecker];
	});
	return syncCheckers;
}

- (TPWAbstractImporter*)suitableImporter {
	for (TPWAbstractImporter *importer in self.suitableImporters) {
		if ([importer canImportFileAtPath:self.path]) {
			return importer;
		}
	}
	return nil;
}

- (NSString*)path {
	return self.reader.path;
}

#pragma mark -
#pragma mark abstract methods

- (void)checkSyncPossibility:(TPWSyncCheckCallback)callback {
	NSAssert(false, @"overwrite this method");
}

- (BOOL)canCheckSync:(NSString*)source {
	NSAssert(false, @"overwrite this method");
	return NO;
}

- (NSArray*)suitableImporters {
	NSAssert(false, @"overwrite this method");
	return nil;
}

@end
