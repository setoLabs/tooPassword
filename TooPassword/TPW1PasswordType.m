//
//  TPW1PasswordTypeNames.m
//  TooPassword
//
//  Created by Tobias Hagemann on 1/23/13.
//
//

#import "TPW1PasswordType.h"
#import "TPW1PasswordItem.h"
#import "TPW1PasswordItemPasswords.h"
#import "TPW1PasswordItemSecureNotes.h"
#import "TPW1PasswordItemWebforms.h"
#import "TPW1PasswordKeyValuePairItem.h"

NSString *const kTPW1PasswordTypehighlightedTypeIconPostfix = @"_highlighted";

@implementation TPW1PasswordType

+ (NSSet*)allSupportedTypes {
	static dispatch_once_t onceToken;
	static NSArray *supportedTypes;
	dispatch_once(&onceToken, ^{
		supportedTypes = @[
			[[TPW1PasswordType alloc] initWithClass:TPW1PasswordKeyValuePairItem.class representingType:@"identities." typeIconName:@"IconIdentities"],
			[[TPW1PasswordType alloc] initWithClass:TPW1PasswordItemPasswords.class representingType:@"passwords." typeIconName:@"IconPasswords"],
			[[TPW1PasswordType alloc] initWithClass:TPW1PasswordItemSecureNotes.class representingType:@"securenotes." typeIconName:@"IconSecurenotes"],
			[[TPW1PasswordType alloc] initWithClass:TPW1PasswordKeyValuePairItem.class representingType:@"wallet." typeIconName:@"IconWallet"],
			[[TPW1PasswordType alloc] initWithClass:TPW1PasswordItemWebforms.class representingType:@"webforms." typeIconName:@"IconWebforms"]
		];
	});
	return [NSSet setWithArray:supportedTypes];
}

#pragma mark - type lifecycle

- (id)initWithClass:(Class)clazz representingType:(NSString*)typePrefix typeIconName:(NSString*)typeIconName {
	if (self = [super init]) {
		self.classRepresentingType = clazz;
		self.typePrefix = typePrefix;
		self.typeIconName = typeIconName;
		self.highlightedTypeIconName = [typeIconName stringByAppendingString:kTPW1PasswordTypehighlightedTypeIconPostfix];
	}
	return self;
}

- (UIImage*)typeIcon {
	return [UIImage imageNamed:self.typeIconName];
}

- (UIImage*)highlightedTypeIcon {
	return [UIImage imageNamed:self.highlightedTypeIconName];
}

#pragma mark - filtering prefixes

+ (NSSet*)matchingTypesForTypeName:(NSString *)typeName stopSearchingAfterFirstMatch:(BOOL)onlyFirstMatch {
	//subset of them, that match the given typeName:
	NSSet *matchingTypes = [[TPW1PasswordType allSupportedTypes] objectsPassingTest:^BOOL(TPW1PasswordType *type, BOOL *stop) {
		if ([typeName hasPrefix:type.typePrefix]) {
			*stop = onlyFirstMatch;
			return YES;
		} else {
			return NO;
		}
	}];
	
	return matchingTypes;
}

+ (TPW1PasswordType*)firstMatchingTypeWithName:(NSString*)typeName {
	return [[TPW1PasswordType matchingTypesForTypeName:typeName stopSearchingAfterFirstMatch:YES] anyObject];
}

+ (TPW1PasswordType*)bestMatchingTypeWithName:(NSString *)typeName {
	NSSet *matchingTypes = [TPW1PasswordType matchingTypesForTypeName:typeName stopSearchingAfterFirstMatch:NO];
	
	//find the longest among the matching prefixes
	TPW1PasswordType *typeWithLongestMatchingPrefix = nil;
	for (TPW1PasswordType *type in matchingTypes) {
		if (type.typePrefix.length > typeWithLongestMatchingPrefix.typePrefix.length) {
			typeWithLongestMatchingPrefix = type;
		}
	}
	
	return typeWithLongestMatchingPrefix;
}

#pragma mark - testing fot the existance of registered types

+ (BOOL)isSupportedType:(NSString *)typeName {
	return [TPW1PasswordType firstMatchingTypeWithName:typeName] != nil;
}

@end
