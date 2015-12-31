//
//  TPWSharedDocumentImportPreparer.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 13.11.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWSharedDocumentImportPreparer : NSObject
	
+ (BOOL)prepareImportFromUrl:(NSURL*)url;

@end
