//
//  TPWRootSplitViewController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWRootViewController.h"

@interface TPWRootSplitViewController : UISplitViewController <UISplitViewControllerDelegate, TPWRootViewController>

@property (nonatomic, strong) TPWItemListTableViewController *itemList;
@property (nonatomic, strong) TPWItemDetailsTableViewController *itemDetails;

@end
