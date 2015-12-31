//
//  TPWRootNavigationController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWNavigationController.h"
#import "TPWRootViewController.h"

@interface TPWRootNavigationController : TPWNavigationController <TPWRootViewController>

@property (nonatomic, strong) TPWItemListTableViewController *itemList;
@property (nonatomic, strong) TPWItemDetailsTableViewController *itemDetails;

- (id)initWithItemList;

@end
