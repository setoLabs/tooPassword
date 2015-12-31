//
//  TPWKeychainSyncNotifications.h
//  TooPassword
//
//  Created by Tobias Hagemann on 2/27/13.
//
//

#import <Foundation/Foundation.h>

@interface TPWKeychainChangeNotifier : NSObject

+ (TPWKeychainChangeNotifier *)sharedInstance;

- (void)registerSyncNotifications;

@end
