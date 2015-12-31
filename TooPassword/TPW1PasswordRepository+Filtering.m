//
//  TPW1PasswordRepository+Filtering.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import "TPW1PasswordRepository+Filtering.h"
#import "TPW1PasswordRepository+Sorting.h"
#import "TPW1PasswordItem.h"

@implementation TPW1PasswordRepository (Filtering)

- (NSArray*)passwordsFilteredUsingSearchTerms:(NSArray*)words searchTitleOnly:(BOOL)simpleSearch {
	NSArray *cleanedTerms = [self cleanedSearchTermArrayFromArray:words];
	return [self filterPasswords:self.passwords usingSearchTerms:cleanedTerms searchTitleOnly:simpleSearch];
}

- (NSArray*)sortedPasswordsFilteredUsingSearchTerms:(NSArray*)words searchTitleOnly:(BOOL)simpleSearch {
	NSArray *cleanedTerms = [self cleanedSearchTermArrayFromArray:words];
	return [self filterPasswords:self.passwordsSortedAlphabetically usingSearchTerms:cleanedTerms searchTitleOnly:simpleSearch];
}

- (NSArray*)filterPasswords:(NSArray*)array usingSearchTerms:(NSArray*)words searchTitleOnly:(BOOL)simpleSearch {
	if (words.count == 0) {
		return array;
	} else {
		NSString *firstWord = [words firstObject];
		NSArray *remainingWords = [words subarrayWithRange:NSMakeRange(1, words.count-1)];
		NSIndexSet *indexesOfItemsMatchingRegexp = [array indexesOfObjectsPassingTest:^BOOL(TPW1PasswordItem *item, NSUInteger idx, BOOL *stop) {
			return [item matchesSearchTerm:firstWord searchTitleOnly:simpleSearch];
		}];
		NSArray *passwordsMatchingFirstWord = [array objectsAtIndexes:indexesOfItemsMatchingRegexp];
		return [self filterPasswords:passwordsMatchingFirstWord usingSearchTerms:remainingWords searchTitleOnly:simpleSearch];
	}
}
- (NSArray*)cleanedSearchTermArrayFromArray:(NSArray*)input {
	NSMutableArray *output = [NSMutableArray arrayWithCapacity:input.count];
	for (NSString *term in input) {
		if (term.length > 0) {
			[output addObject:term];
		}
	}
	return output;
}


@end
