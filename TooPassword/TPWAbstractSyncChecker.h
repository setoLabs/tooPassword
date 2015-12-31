//
//  TPWAbstractSyncChecker.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 11.05.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWMetadataReader.h"
#import "TPWAbstractImporter.h"

typedef void(^TPWSyncCheckCallback)(BOOL syncIsPossible, BOOL hasChanges);

@interface TPWAbstractSyncChecker : NSObject

@property (nonatomic, strong) TPWMetadataReader *reader;

+ (TPWAbstractSyncChecker*)syncChecker;
- (TPWAbstractImporter*)suitableImporter;
- (NSString*)path;

// to be overwritten by subclasses
- (void)checkSyncPossibility:(TPWSyncCheckCallback)callback;
- (BOOL)canCheckSync:(NSString*)source;
- (NSArray*)suitableImporters;

@end
