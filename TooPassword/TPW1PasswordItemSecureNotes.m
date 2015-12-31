//
//  TPW1PasswordItemSecureNotes.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 25.01.13.
//
//

#import "TPW1PasswordItemSecureNotes.h"
#import "TPWGroupedTableViewCell.h"
#import "NSString+TPWExtensions.h"

@implementation TPW1PasswordItemSecureNotes

#pragma mark - searching

- (BOOL)matchesSearchTerm:(NSString*)word searchTitleOnly:(BOOL)simpleSearch {
	if (simpleSearch) {
		return [super matchesSearchTerm:word searchTitleOnly:simpleSearch];
	}
	NSString *haystack = [NSString haystackUsingHay:self.title ? : @"", self.location ? : @"", self.notesPlain ? : @"", nil];
	return [haystack rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (CGFloat)preferredHeightForRowAtIndexPath:(NSIndexPath *)indexPath inTableView:(UITableView *)tableView {
	return [super preferredHeightForNotesRowInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [super cellForNotesRowInTableView:tableView];
}

- (TPW1PasswordItemActions*)actionsForRowInTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
	return [[TPW1PasswordItemActions alloc] initWithActionsForText:self.notesPlain];
}

@end
