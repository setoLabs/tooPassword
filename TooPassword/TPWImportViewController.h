//
//  TPWImportViewController.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWTableDialogScreen.h"
#import "TPWAbstractDirectoryBrowser.h"

@class TPWImportViewController;

@protocol TPWImportViewControllerDelegate <NSObject>
- (void)importViewControllerFinishedSuccessfully:(TPWImportViewController*)importViewController;
- (void)importViewController:(TPWImportViewController*)importViewController failedWithError:(NSError*)error;
@end

@interface TPWImportViewController : TPWTableDialogScreen

@property (nonatomic, weak) NSObject<TPWImportViewControllerDelegate> *delegate;

- (id)initWithDirectoryBrowser:(TPWAbstractDirectoryBrowser *)directoryBrowser;
- (id)initWithDirectoryBrowser:(TPWAbstractDirectoryBrowser *)directoryBrowser directoryName:(NSString*)directoryName;

@end
