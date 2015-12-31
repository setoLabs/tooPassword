//
//  TPWWebDAVZipImporter.h
//  TooPassword
//
//  Created by Tobias Hagemann on 11/12/13.
//
//

#import "TPWAbstractZipImporter.h"

@interface TPWWebDAVZipImporter : TPWAbstractZipImporter

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

@end
