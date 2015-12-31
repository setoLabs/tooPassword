//
//  TPWItemListTableViewController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>

@class TPW1PasswordItem;

@interface TPWItemListTableViewController : UITableViewController
@property (nonatomic, weak) TPW1PasswordItem *selectedItem;

- (void)reloadPasswordsAnimated:(BOOL)animated;

@end
