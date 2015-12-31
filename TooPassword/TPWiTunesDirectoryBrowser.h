//
//  TPWiTunesDirectoryBrowser.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import "TPWAbstractDirectoryBrowser.h"

@interface TPWiTunesDirectoryBrowser : TPWAbstractDirectoryBrowser

- (id)initWithWorkingDirectory:(NSString *)path basePath:(NSString*)basePath;

@end
