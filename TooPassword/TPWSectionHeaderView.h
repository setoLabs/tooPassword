//
//  TPWSectionHeaderView.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import <UIKit/UIKit.h>

extern CGFloat const kTPWSectionHeaderViewHeight;

@interface TPWSectionHeaderView : UILabel

@property (nonatomic, assign) BOOL drawSectionSeparator;

- (id)initWithText:(NSString*)text;

@end
