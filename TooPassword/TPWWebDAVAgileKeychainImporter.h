//
//  TPWWebDAVAgileKeychainImporter.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.11.13.
//
//

#import "TPWAbstractAgileKeychainImporter.h"

@interface TPWWebDAVAgileKeychainImporter : TPWAbstractAgileKeychainImporter

- (instancetype)initWithUsername:(NSString *)username password:(NSString *)password;

@end
