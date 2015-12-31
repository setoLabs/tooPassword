//
//  TPWSettingsScreen.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/18/13.
//
//

#import "TPWTableDialogScreen.h"

@interface TPWSettingsScreen : TPWTableDialogScreen

- (id)initWithDoneButtonShown:(BOOL)doneButtonShown;
- (void)presentDropboxImporter;
- (void)presentiTunesImporter;

@end
