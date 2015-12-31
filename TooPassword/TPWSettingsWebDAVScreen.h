//
//  TPWSettingsWebDAVScreen.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.11.13.
//
//

#import "TPWTableDialogScreen.h"
#import "TPWImportViewController.h"

@interface TPWSettingsWebDAVScreen : TPWTableDialogScreen
@property (nonatomic, weak) id<TPWImportViewControllerDelegate> importFinishedDelegate;

- (id)initWithImportFinishedDelegate:(id<TPWImportViewControllerDelegate>)importFinishedDelegate;

@end
