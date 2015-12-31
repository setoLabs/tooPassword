//
//  TPWReachability.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 07.02.13.
//
//

#import "TPWReachability.h"

@implementation TPWReachability

+ (BOOL)dropboxIsReachable {
	return [TPWReachability hostIsReachable:@"dropbox.com"];
}

+ (BOOL)hostIsReachable:(NSString*)host {
	Reachability *reachability = [Reachability reachabilityWithHostName:host];
	NetworkStatus internetStatus = [reachability currentReachabilityStatus];
	return (internetStatus != NotReachable);
}

- (id)initWithHostname:(NSString*)hostname onChange:(TPWReachabilityChangedFeedback)feedback {
	if (self = [super init]) {
		self.feedback = feedback;
		self.reachability = [Reachability reachabilityWithHostName:hostname];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:self.reachability];
		[self.reachability startNotifier];
	}
	return self;
}

- (void)reachabilityChanged:(NSNotification*)notification {
	self.feedback(self.reachability);
}

- (void)dealloc {
	[self.reachability stopNotifier];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	//[super dealloc]; done by ARC
}

@end
