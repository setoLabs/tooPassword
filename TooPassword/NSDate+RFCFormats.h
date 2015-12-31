//
//  NSDate+RFCFormats.h
//  TooPassword
//
//  Created by Tobias Hagemann on 27/10/13.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (RFCFormats)

+ (NSDate *)dateFromRFC822:(NSString *)date;
- (NSString *)rfc822String;

@end
