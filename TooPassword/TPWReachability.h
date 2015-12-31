//
//  TPWReachability.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 07.02.13.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"

typedef void(^TPWReachabilityChangedFeedback)(Reachability *reachability);

@interface TPWReachability : NSObject
@property (nonatomic, strong) Reachability *reachability;
@property (nonatomic, copy) TPWReachabilityChangedFeedback feedback;

+ (BOOL)dropboxIsReachable;
+ (BOOL)hostIsReachable:(NSString*)host;

/**
 * if you init this, you must also release this, as it keeps on spamming notifications to you, until it dies!
 */
- (id)initWithHostname:(NSString*)hostname onChange:(TPWReachabilityChangedFeedback)feedback;

@end
