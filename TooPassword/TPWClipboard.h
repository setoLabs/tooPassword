//
//  TPWClipboard.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 26.01.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWClipboard : NSObject

@property (nonatomic, assign) UIBackgroundTaskIdentifier clipboardClearTask;
@property (nonatomic, strong) NSData *md5OfLatestCopiedString;

- (BOOL)hasItemInClipboard;

- (void)scheduleClipboardClearTask;
- (void)cancelClipboardClearTask;

- (void)clearClipboardIfStillContainingCopiedData;
- (void)copyToClipboard:(NSString*)string;

+ (TPWClipboard*)sharedClipboard;

@end
