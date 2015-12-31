//
//  TPWDropboxDirectoryBrowser.m
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import <DropboxSDK/DropboxSDK.h>
#import "TPWReachability.h"

#import "TPWDropboxDirectoryBrowser.h"
#import "TPWDropboxAgileKeychainImporter.h"
#import "TPWDropboxZipImporter.h"

NSString *const kTPWDropboxDirectoryBrowserErrorDomain = @"TPWDropboxDirectoryBrowserErrorDomain";

@interface TPWDropboxDirectoryBrowser () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient *restClient;
@property (nonatomic, assign) BOOL loadInProgress;
@end

@implementation TPWDropboxDirectoryBrowser

- (TPWAbstractDirectoryBrowser *)browserForWorkingDirectory:(NSString *)path {
	return [[TPWDropboxDirectoryBrowser alloc] initWithWorkingDirectory:path];
}

- (void)contentsOfDirectory:(TPWContentsOfDirectoryCallback)callback {
	[super contentsOfDirectory:callback];
	
	// Check if dropbox is reachable.
	if (![TPWReachability dropboxIsReachable]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWDropboxDirectoryBrowserErrorDomain code:TPWDropboxDirectoryBrowserErrorDropboxNotReachable userInfo:nil];
		callback(nil, error);
		return;
	}
	
	// Check if dropbox is linked.
	if (![[DBSession sharedSession] isLinked]) {
		NSError *error = [[NSError alloc] initWithDomain:kTPWDropboxDirectoryBrowserErrorDomain code:TPWDropboxDirectoryBrowserErrorDropboxNotLinked userInfo:nil];
		callback(nil, error);
		return;
	}
	
	// Load Dropbox Metadata.
	self.loadInProgress = YES;
	[self initializeRestClient];
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.restClient loadMetadata:self.path];
	});
}

- (void)cancel {
	if (self.loadInProgress) {
		self.loadInProgress = NO;
		
		// cancel
		self.restClient.delegate = nil;
		[self.restClient cancelAllRequests];
		
		// callback
		NSError *error = [[NSError alloc] initWithDomain:kTPWDropboxDirectoryBrowserErrorDomain code:TPWDropboxDirectoryBrowserErrorInterrupted userInfo:nil];
		self.callback(nil, error);
	}
}

- (NSArray *)suitableImporters {
	TPWDropboxAgileKeychainImporter *agileKeychainImporter = [[TPWDropboxAgileKeychainImporter alloc] init];
	TPWDropboxZipImporter *zipImporter = [[TPWDropboxZipImporter alloc] init];
	return @[agileKeychainImporter, zipImporter];
}

- (void)initializeRestClient {
	if (!self.restClient) {
		self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
		self.restClient.delegate = self;
	}
}

- (NSString*)secondaryActionButtonTitle {
	return NSLocalizedString(@"keychainSync.keychainImportController.dropboxSignOut", @"Sign out button title for dropbox file browser");
}

- (BOOL)performSecondaryActionAndContinueBrowsingIfWithoutError:(NSError **)error {
	[[DBSession sharedSession] unlinkAll];
	if (error != NULL) {
		*error = [[NSError alloc] initWithDomain:kTPWDropboxDirectoryBrowserErrorDomain code:TPWDropboxDirectoryBrowserErrorInterrupted userInfo:nil];
		return NO;
	}
	return YES;
}

#pragma mark -
#pragma mark DBRestClientDelegate

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
	NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:metadata.contents.count];

	for (DBMetadata *item in metadata.contents) {
		if (item.isDirectory || [self canImportFileAtPath:item.path]) {
			result[item.path] = item.filename;
		}
	}

	self.loadInProgress = NO;
	self.callback(result, nil);
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
	self.loadInProgress = NO;
	self.callback(nil, error);
}

@end
