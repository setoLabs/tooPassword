//
//  TPWDropboxDirectoryBrowser.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWAbstractDirectoryBrowser.h"

typedef enum {
	TPWDropboxDirectoryBrowserErrorDropboxNotReachable,
	TPWDropboxDirectoryBrowserErrorDropboxNotLinked,
	TPWDropboxDirectoryBrowserErrorInterrupted
} TPWDropboxDirectoryBrowserError;

extern NSString *const kTPWDropboxDirectoryBrowserErrorDomain;

@interface TPWDropboxDirectoryBrowser : TPWAbstractDirectoryBrowser

@end
