//
//  TPWSharedDocumentImportPreparer.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 13.11.13.
//
//

#import "TPWSharedDocumentImportPreparer.h"
#import "TPWFileUtil.h"

@implementation TPWSharedDocumentImportPreparer

+ (BOOL)prepareImportFromUrl:(NSURL*)url {
	NSString *inboxPath = [TPWFileUtil documentsInboxPath];
	
	// step 0: check if url points to inbox
	if ([[url resourceSpecifier] rangeOfString:inboxPath].location == NSNotFound) {
		return NO;
	}
	
	NSError *error = nil;
	
	// step 1: move from inbox
	NSString *filename = [url lastPathComponent];
	NSString *destPath = [[TPWFileUtil documentsPath] stringByAppendingPathComponent:filename];
	[[NSFileManager defaultManager] removeItemAtPath:destPath error:nil];
	[[NSFileManager defaultManager] moveItemAtPath:[url resourceSpecifier] toPath:destPath error:&error];
	
	// step 2: remove inbox
	NSError *error2 = nil;
	[[NSFileManager defaultManager] removeItemAtPath:inboxPath error:&error2];
	
	// step 3: there is no step 3
	return error == nil;
}

@end
