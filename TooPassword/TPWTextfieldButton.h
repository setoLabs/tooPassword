//
//  TPWTextfieldButton.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 10.02.13.
//
//

#import "TPWButton.h"

@interface TPWTextfieldButton : TPWButton

+ (TPWButton *)tpwTextfieldButtonWithTitle:(NSString*)title target:(id)target action:(SEL)action;

@end
