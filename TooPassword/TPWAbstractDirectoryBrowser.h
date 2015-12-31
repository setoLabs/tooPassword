//
//  TPWAbstractDirectoryBrowser.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import <Foundation/Foundation.h>
#import "TPWImportableFileChecking.h"
#import "TPWAbstractImporter.h"

/**
 @param contents	NSDictionary{path: displayName} containing importable elements as well as subdirectories of directory, or nil in case of error.
 @param error		Error or nil.
 */
typedef void(^TPWContentsOfDirectoryCallback)(NSDictionary *contents, NSError *error);

@interface TPWAbstractDirectoryBrowser : NSObject <TPWImportableFileChecking>

@property (nonatomic, strong) NSString *path;
@property (nonatomic, copy) TPWContentsOfDirectoryCallback callback;

- (id)initWithWorkingDirectory:(NSString *)path;
- (TPWAbstractDirectoryBrowser *)browserForWorkingDirectory:(NSString *)path;
- (NSString *)relativeWorkingDirectoryForDisplay;
- (BOOL)contentsOfDirectoryWillLoadImmediately;
- (void)contentsOfDirectory:(TPWContentsOfDirectoryCallback)callback;
- (void)cancel;
- (NSArray *)suitableImporters;
- (TPWAbstractImporter *)importerForKeychainAtPath:(NSString *)path;

- (NSString*)secondaryActionButtonTitle;
- (BOOL)performSecondaryActionAndContinueBrowsingIfWithoutError:(NSError **)error;

@end
