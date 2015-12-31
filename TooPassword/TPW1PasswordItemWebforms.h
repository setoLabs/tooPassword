//
//  TPW1PasswordItemWebforms.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 23.01.13.
//
//

#import "TPW1PasswordItem.h"

extern NSString *const kTPW1PasswordItemWebformsJsonKeyFields_name;
extern NSString *const kTPW1PasswordItemWebformsJsonKeyFields_value;

@interface TPW1PasswordItemWebforms : TPW1PasswordItem

@property (nonatomic, strong) NSArray *fields;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end
