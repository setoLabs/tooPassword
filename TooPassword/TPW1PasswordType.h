//
//  TPW1PasswordTypeNames.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/23/13.
//
//

#import <Foundation/Foundation.h>

@interface TPW1PasswordType : NSObject

@property (nonatomic, assign) Class classRepresentingType;
@property (nonatomic, strong) NSString *typePrefix;
@property (nonatomic, strong) NSString *typeIconName;
@property (nonatomic, strong) NSString *highlightedTypeIconName;
@property (nonatomic, readonly) UIImage *typeIcon;
@property (nonatomic, readonly) UIImage *highlightedTypeIcon;

#pragma mark - class methods

/**
 \return the first matching type from all known types for the given typeName. Returns nil, if no prefix matches.
 */
+ (TPW1PasswordType*)firstMatchingTypeWithName:(NSString*)typeName;

/**
 \return the type with the longest matching prefix from all known types for the given typeName. Returns nil, if no prefix matches.
 */
+ (TPW1PasswordType*)bestMatchingTypeWithName:(NSString *)typeName;

/**
 \return NSSet containing all known types
 */
+ (NSSet*)allSupportedTypes;

/**
 \return YES, if the typeName starts with a known prefix
 */
+ (BOOL)isSupportedType:(NSString *)typeName;

@end
