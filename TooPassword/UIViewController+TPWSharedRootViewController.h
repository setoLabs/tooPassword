//
//  UIViewController+TPWSharedRootViewController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWRootViewController.h"

@interface UIViewController (TPWSharedRootViewController)

@property (nonatomic, readonly) UIViewController<TPWRootViewController> *sharedTPWRootViewController;

@end
