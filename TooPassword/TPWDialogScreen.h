//
//  TPWDialogScreen.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWBarButtonItem.h"

@interface TPWDialogScreen : UIViewController

- (id)initWithUniversalNibName:(NSString*)universalNibName;
- (void)dismissDialogScreenAnimated:(BOOL)animated;

@end
