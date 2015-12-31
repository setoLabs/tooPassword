//
//  TPW1PasswordRepository+Grouping.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import "TPW1PasswordRepository+Grouping.h"
#import "TPW1PasswordRepository+Sorting.h"
#import "TPW1PasswordItem.h"

static NSUInteger const kTPWEstimatedNumberOfGroups = 30; //slightly larger then roman alphabet.
static NSString *const kTPWPasswordAlphabeticalGroupingDefaultGroup = @"#";

@implementation TPW1PasswordRepository (Grouping)

/**
 \return two-dimensional structure: @{A: [Amazon, Apple], G: [Google Mail, Google Talk], X: [Xing]}
 */
- (NSDictionary*)passwordsGroupedAlphabetically {
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:kTPWEstimatedNumberOfGroups];
	for (TPW1PasswordItem *pw in self.passwordsSortedAlphabetically) {
		NSString *group = [self firstUppercaseAsciiLetterOfString:pw.title];
		NSMutableArray *pws = dict[group];
		if (!pws) {
			pws = [NSMutableArray arrayWithObject:pw];
			dict[group] = pws;
		} else {
			[pws addObject:pw];
		}
	}
	
	return dict;
}

- (NSString*)firstUppercaseAsciiLetterOfString:(NSString*)str {
	//convert to uppercase ascii data
	NSString *uppercase = [str uppercaseString];
	NSData *asciiData = [uppercase dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	if (asciiData.length == 0) {
		return kTPWPasswordAlphabeticalGroupingDefaultGroup;
	}
	
	//get first character and fallback to defaultGroup for letters outside of range A-Z
	const unsigned char* letters = asciiData.bytes;
	unichar firstLetter = letters[0];
	if (firstLetter < 'A' || firstLetter > 'Z') {
		return kTPWPasswordAlphabeticalGroupingDefaultGroup;
	} else {
		return [[NSString alloc] initWithBytes:letters length:1 encoding:NSASCIIStringEncoding];
	}
}


@end
