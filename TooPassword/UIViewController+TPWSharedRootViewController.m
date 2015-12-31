//
//  UIViewController+TPWSharedRootViewController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import "UIViewController+TPWSharedRootViewController.h"
#import "TPWAppDelegate.h"

@implementation UIViewController (TPWSharedRootViewController)

- (UIViewController<TPWRootViewController>*)sharedTPWRootViewController {
	TPWAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
	NSAssert([appDelegate isKindOfClass:TPWAppDelegate.class], @"App Delegate must be of type TPWAppDelegate");
	return [appDelegate rootViewController];
}

@end
