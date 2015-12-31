//
//  TPWItemDetailsTableViewController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPW1PasswordItem.h"

@interface TPWItemDetailsTableViewController : UITableViewController

@property (nonatomic, weak) TPW1PasswordItem *passwordItem;

- (id)initWithPasswordItem:(TPW1PasswordItem*)item;

@end
