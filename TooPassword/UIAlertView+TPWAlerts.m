//
//  UIAlertView+TPWAlerts.m
//  TooPassword
//
//  Created by Tobias Hagemann on 2/10/13.
//
//

#import "UIAlertView+TPWAlerts.h"

@implementation UIAlertView (TPWAlerts)

+ (UIAlertView *)tpwDropboxNotReachableAlert {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ui.alerts.title", @"alerts - title")
														message:NSLocalizedString(@"ui.alerts.dropboxNotReachableAlert.message", @"dropbox not reachable alert - message")
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"ui.common.dismiss", @"dismiss")
											  otherButtonTitles:nil];
	return alertView;
}

+ (UIAlertView *)tpwAlertWithError:(NSError*)error {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ui.alerts.title", @"alerts - title")
														message:error.localizedDescription
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"ui.common.dismiss", @"dismiss")
											  otherButtonTitles:nil];
	return alertView;
}

@end
