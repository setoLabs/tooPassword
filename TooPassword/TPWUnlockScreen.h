//
//  TPWUnlockScreen.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.01.13.
//
//

#import <UIKit/UIKit.h>
#import "TPWDialogScreen.h"
#import "TPWTextfieldButton.h"

@interface TPWUnlockScreen : TPWDialogScreen

@property (nonatomic, weak) IBOutlet UITextField *masterPasswordField;
@property (nonatomic, weak) IBOutlet TPWTextfieldButton *unlockButton;
@property (nonatomic, weak) IBOutlet UILabel *passwordHintLabel;

- (IBAction)unlock:(id)sender;
- (IBAction)textFieldDidChange:(id)sender;

@end
