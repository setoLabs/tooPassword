//
//  TPWiTunesZipImporter.m
//  TooPassword
//
//  Created by Tobias Hagemann on 7/5/13.
//
//

#import "TPWFileUtil.h"

#import "TPWiTunesZipImporter.h"

@implementation TPWiTunesZipImporter

#pragma mark -
#pragma mark TPWFileImporter

- (void)loadFile:(NSString *)sourcePath intoPath:(NSString *)destinationPath onCompletion:(TPWLoadFileCallback)callback onProgress:(TPWLoadFileProgressCallback)progressCallback {
	NSParameterAssert(sourcePath);
	NSParameterAssert(destinationPath);
	NSParameterAssert(callback);
	
	NSError *error = nil;
	BOOL success = [[NSFileManager defaultManager] moveItemAtPath:sourcePath toPath:destinationPath error:&error];
	callback(success, error);
}

@end
