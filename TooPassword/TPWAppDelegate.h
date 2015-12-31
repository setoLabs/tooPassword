//
//  TPWAppDelegate.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWRootViewController.h"

@interface TPWAppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController<TPWRootViewController> *rootViewController;

@end
