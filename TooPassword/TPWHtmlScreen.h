//
//  TPWHtmlScreen.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.02.13.
//
//

#import "TPWDialogScreen.h"

@interface TPWHtmlScreen : TPWDialogScreen

@property (nonatomic, weak) IBOutlet UIWebView *webview;

- (id)initWithTitle:(NSString *)title htmlPathName:(NSString *)htmlPathName;

@end
