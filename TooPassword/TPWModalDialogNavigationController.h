//
//  TPWModalDialogNavigationController.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWNavigationController.h"

@interface TPWModalDialogNavigationController : TPWNavigationController

- (id)initWithDialog:(UIViewController*)dialog;
- (id)initWithWelcomeScreen;
- (id)initWithUnlockScreen;
- (id)initWithSettingsScreen;

@end
