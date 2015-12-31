//
//  TPW1PasswordKeyValuePairItem.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import "TPW1PasswordItem.h"
#import "TPW1PasswordFieldKeyUtil.h"

@interface TPW1PasswordKeyValuePairItem : TPW1PasswordItem

@property (nonatomic, strong) NSArray *keys;
@property (nonatomic, strong) NSDictionary *keyValuePairs;

@end
