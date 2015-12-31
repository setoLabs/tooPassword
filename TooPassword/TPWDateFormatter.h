//
//  TPWDateFormatter.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWDateFormatter : NSObject
@property (nonatomic, strong) NSMutableDictionary *dateFormatters;

+ (NSDateFormatter*)dateFormatterWithFormat:(NSString*)format;
+ (NSDateFormatter*)localizedDMYDateFormatter;
+ (NSDateFormatter*)localizedDMDateFormatter;

@end
