//
//  TPWAddressFormat.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 17.02.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWAddressComponent.h"

extern NSString *const kTPWAddressFormatComponentsJsonKey;

@interface TPWAddressFormat : TPWAddressComponent

@property (nonatomic, strong) NSArray *components;

@end
