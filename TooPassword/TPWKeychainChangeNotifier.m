//
//  TPWKeychainSyncNotifications.m
//  TooPassword
//
//  Created by Tobias Hagemann on 2/27/13.
//
//

#import "TPWConstants.h"
#import "TPWFileUtil.h"
#import "TPWReachability.h"
#import "DirectoryWatcher.h"
#import "TPWSettings.h"

#import "TPWKeychainChangeNotifier.h"

@interface TPWKeychainChangeNotifier () <DirectoryWatcherDelegate>
@property (nonatomic, strong) TPWReachability *dropboxReachability;
@property (nonatomic, strong) DirectoryWatcher *documentsDirWatcher;
@property (nonatomic, strong) TPWReachability *webDAVReachability;
@end

@implementation TPWKeychainChangeNotifier

static TPWKeychainChangeNotifier *sharedInstance = nil;

+ (TPWKeychainChangeNotifier *)sharedInstance {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

#pragma mark -
#pragma mark Helpers

- (void)registerSyncNotifications {
	// Dropbox
	self.dropboxReachability = [[TPWReachability alloc] initWithHostname:@"dropbox.com" onChange:^(Reachability *reachability) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
	}];
	
	// iTunes
	self.documentsDirWatcher = [DirectoryWatcher watchFolderWithPath:[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] delegate:self];
	
	// WebDAV
	if ([TPWSettings webDAVUrl].length > 0) {
		NSURL *url = [NSURL URLWithString:[TPWSettings webDAVUrl]];
		self.webDAVReachability = [[TPWReachability alloc] initWithHostname:url.host onChange:^(Reachability *reachability) {
			[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
		}];
	}
}

#pragma mark -
#pragma mark DirectoryWatcherDelegate

- (void)directoryDidChange:(DirectoryWatcher *)folderWatcher {
	[[NSNotificationCenter defaultCenter] postNotificationName:kTPWNotificationCheckSyncPossiblity object:self];
}

@end
