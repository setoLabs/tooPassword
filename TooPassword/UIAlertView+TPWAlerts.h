//
//  UIAlertView+TPWAlerts.h
//  TooPassword
//
//  Created by Tobias Hagemann on 2/10/13.
//
//

#import <UIKit/UIKit.h>

@interface UIAlertView (TPWAlerts)

+ (UIAlertView *)tpwDropboxNotReachableAlert;
+ (UIAlertView *)tpwAlertWithError:(NSError*)error;

@end
