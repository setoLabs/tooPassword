//
//  TPWMetadataReader.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 29.04.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWMetadataPersistence.h"

@interface TPWMetadataReader : NSObject
@property (nonatomic, strong) NSDate *importDate;
@property (nonatomic, strong) NSDate *modificationDate;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSDictionary *revisionNumbers;

+ (TPWMetadataReader*)reader;

// to be overwritten by subclasses
- (void)readDictionary:(NSDictionary*)dict;
- (BOOL)canReadFormat:(NSString*)format version:(NSString*)version;

@end
