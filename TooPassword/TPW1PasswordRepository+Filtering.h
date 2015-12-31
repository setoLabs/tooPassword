//
//  TPW1PasswordRepository+Filtering.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 21.01.13.
//
//

#import "TPW1PasswordRepository.h"

@interface TPW1PasswordRepository (Filtering)

- (NSArray*)passwordsFilteredUsingSearchTerms:(NSArray*)words searchTitleOnly:(BOOL)simpleSearch;
- (NSArray*)sortedPasswordsFilteredUsingSearchTerms:(NSArray*)words searchTitleOnly:(BOOL)simpleSearch;

@end
