//
//  TPWImportableFileChecking.h
//  TooPassword
//
//  Created by Tobias Hagemann on 3/23/13.
//
//

#import <Foundation/Foundation.h>

@protocol TPWImportableFileChecking <NSObject>

- (BOOL)canImportFileAtPath:(NSString *)path;

@end
