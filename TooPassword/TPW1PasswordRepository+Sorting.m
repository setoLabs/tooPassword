//
//  TPW1PasswordRepository+Sorting.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import "TPW1PasswordRepository+Sorting.h"
#import "TPW1PasswordItem.h"

@implementation TPW1PasswordRepository (Sorting)

- (NSArray*)passwordsSortedAlphabetically {
	return [self.passwords sortedArrayUsingComparator:^NSComparisonResult(TPW1PasswordItem *pw1, TPW1PasswordItem *pw2) {
		return [pw1.title compare:pw2.title options:NSCaseInsensitiveSearch|NSNumericSearch|NSDiacriticInsensitiveSearch|NSWidthInsensitiveSearch];
	}];
}

@end
