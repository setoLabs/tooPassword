//
//  TPWProgressHUD.m
//  TooPassword
//
//  Created by Tobias Hagemann on 7/24/13.
//
//

#import "TPWProgressHUD.h"

@implementation TPWProgressHUD

- (NSTimeInterval)displayDurationForString:(NSString*)string {
	return string.length * 0.06 + 1.0;
}

@end
