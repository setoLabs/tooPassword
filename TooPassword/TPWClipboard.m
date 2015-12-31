//
//  TPWClipboard.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 26.01.13.
//
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "NSData+MD5.h"

#import "TPWClipboard.h"
#import "TPWSettings.h"

@implementation TPWClipboard

- (BOOL)hasItemInClipboard {
	NSString *stringInPasteboard = [[UIPasteboard generalPasteboard] valueForPasteboardType:(NSString*)kUTTypeUTF8PlainText];
	NSData *md5OfStringInPasteboard = [[stringInPasteboard dataUsingEncoding:NSUTF8StringEncoding] md5];
	//item exists and checksum matches (we don't care for pasteboard content from other applications)
	return (stringInPasteboard != nil && [md5OfStringInPasteboard isEqualToData:self.md5OfLatestCopiedString]);
}

#pragma mark - background tasks

- (void)scheduleClipboardClearTask {
	if (![self hasItemInClipboard] || [TPWSettings clearClipboardTimeInterval] == kTPWSettingsClearClipboardTimeIntervalNever) {
		return;
	}
	
	__weak TPWClipboard *weakSelf = self;
	self.clipboardClearTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
		[weakSelf cancelClipboardClearTask];
	}];
	
	dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
	dispatch_async(backgroundQueue, ^{
		[NSThread sleepForTimeInterval:[TPWSettings clearClipboardTimeInterval]];
		if (weakSelf.clipboardClearTask != UIBackgroundTaskInvalid && [weakSelf hasItemInClipboard]) {
			[weakSelf clearClipboardIfStillContainingCopiedData];
			UILocalNotification *notification = [[UILocalNotification alloc] init];
			notification.hasAction = NO;
			notification.alertBody = NSLocalizedString(@"notifications.clipboardGotCleared", @"'clipboard has been cleared' notification text");
			notification.soundName = UILocalNotificationDefaultSoundName;
			[[UIApplication sharedApplication] presentLocalNotificationNow:notification];
			[weakSelf cancelClipboardClearTask];
		}
	});
}

- (void)cancelClipboardClearTask {
	__weak TPWClipboard *weakSelf = self;
	dispatch_async(dispatch_get_main_queue(), ^{
		if (weakSelf.clipboardClearTask != UIBackgroundTaskInvalid) {
			[[UIApplication sharedApplication] endBackgroundTask:weakSelf.clipboardClearTask];
			weakSelf.clipboardClearTask = UIBackgroundTaskInvalid;
		}
	});
}

#pragma mark - pasteboard logic

- (void)clearClipboardIfStillContainingCopiedData {
	if (self.hasItemInClipboard) {
		DLog(@"clipboard cleared");
		self.md5OfLatestCopiedString = nil;
		[[UIPasteboard generalPasteboard] setItems:nil];
	}
}

- (void)copyToClipboard:(NSString*)string {
	self.md5OfLatestCopiedString = [[string dataUsingEncoding:NSUTF8StringEncoding] md5];
	[[UIPasteboard generalPasteboard] setValue:string forPasteboardType:(NSString*)kUTTypeUTF8PlainText];
}

#pragma mark - lifecycle

+ (TPWClipboard*)sharedClipboard {
	static dispatch_once_t onceToken;
	static TPWClipboard *instance;
	dispatch_once(&onceToken, ^{
		instance = [[TPWClipboard alloc] init];
	});
	return instance;
}

@end
