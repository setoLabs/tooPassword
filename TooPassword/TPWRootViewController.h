//
//  TPWRootViewController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWItemListTableViewController.h"
#import "TPWItemDetailsTableViewController.h"
#import "TPWModalDialogNavigationController.h"

@class TPW1PasswordItem;

@protocol TPWRootViewController <NSObject>

- (TPWItemListTableViewController*)itemList;
- (TPWItemDetailsTableViewController*)itemDetails;

- (void)wipeScreenAnimated:(BOOL)animated;
- (void)refreshItemListAnimated:(BOOL)animated;
- (void)showDetailsOfItem:(TPW1PasswordItem*)item;

- (void)presentModalDialog:(TPWModalDialogNavigationController*)modalDialog animated:(BOOL)animated;

@end
