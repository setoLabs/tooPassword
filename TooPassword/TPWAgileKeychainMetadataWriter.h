//
//  TPWAgileKeychainMetadataWriter.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 22.04.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWAgileKeychainMetadataWriter : NSObject
@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSDictionary *revisionNumbers;

- (void)writeMetadataToFile;

@end
