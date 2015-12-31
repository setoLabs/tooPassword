//
//  TPWWelcomeScreen.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/12/13.
//
//

#import "TPWDialogScreen.h"
#import "TPWButton.h"

@interface TPWWelcomeScreen : TPWDialogScreen

@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet TPWButton *importFromDropboxButton;
@property (nonatomic, weak) IBOutlet TPWButton *importFromiTunesButton;
@property (nonatomic, weak) IBOutlet TPWButton *importFromWebDAVButton;
@property (nonatomic, weak) IBOutlet TPWButton *helpButton;

- (IBAction)presentDropboxImporter:(id)sender;
- (IBAction)presentiTunesImporter:(id)sender;
- (IBAction)presentWebDAVImporter:(id)sender;
- (IBAction)presentHelpScreen:(id)sender;

@end
