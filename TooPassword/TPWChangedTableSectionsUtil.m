//
//  TPWChangedTableSectionsUtil.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 06.02.13.
//
//

#import "TPWChangedTableSectionsUtil.h"

@implementation TPWChangedTableSectionsUtil

+ (void)updateTable:(UITableView*)tableView byComparingSectionsBefore:(NSArray*)sectionsBefore cellsBefore:(NSDictionary*)cellsBefore withSectionsAfter:(NSArray*)sectionsAfter cellsAfter:(NSDictionary*)cellsAfter {
	[tableView beginUpdates];
	
	//1. delete
	NSArray *sectionsToDelete = [self removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSIndexSet *indexesOfSectionsToDelete = [self indexOfSectionsToBeRemoved:sectionsToDelete fromSections:sectionsBefore];
	[tableView deleteSections:indexesOfSectionsToDelete withRowAnimation:UITableViewRowAnimationFade];
	
	//2. add new
	NSArray *sectionsToAdd = [self addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSIndexSet *indexesOfSectionsToAdd = [self indexOfSectionsToBeAdded:sectionsToAdd intoSections:sectionsBefore];
	[tableView insertSections:indexesOfSectionsToAdd withRowAnimation:UITableViewRowAnimationFade];
	
	//3. reload changed cells
	NSArray *commonSections = [self commonSectionsInSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSDictionary *cellsAfterInCommonSections = [cellsAfter dictionaryWithValuesForKeys:commonSections];
	NSDictionary *cellsBeforeInCommonSections = [cellsBefore dictionaryWithValuesForKeys:commonSections];
	NSArray *changedSections = [self changedSectionsByComparingCellsBefore:cellsBeforeInCommonSections withCellsAfter:cellsAfterInCommonSections];
	NSIndexSet *indexesOfChangedSections = [self indexOfSectionsThatChanged:changedSections inSections:commonSections];
	[tableView reloadSections:indexesOfChangedSections withRowAnimation:UITableViewRowAnimationFade];

	[tableView endUpdates];
}

#pragma mark - adding

+ (NSIndexSet*)indexOfSectionsToBeAdded:(NSArray*)sectionsToBeAdded intoSections:(NSArray*)sections {
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	NSUInteger addedSectionCount = 0;
	for (NSString *keyToAdd in sectionsToBeAdded) {
		NSUInteger indexInSections = [self indexOfSectionToBeAdded:keyToAdd inExistingSections:sections] + addedSectionCount;
		[indexSet addIndex:indexInSections];
		addedSectionCount++;
	}
	return indexSet;
}

+ (NSUInteger)indexOfSectionToBeAdded:(NSString*)keyToAdd inExistingSections:(NSArray*)sections {
	NSAssert(![sections containsObject:sections], @"can not add an already existing section");
	//find index of first alphabetically following item
	for (NSString *existingKey in sections) {
		if ([keyToAdd compare:existingKey] == NSOrderedAscending) {
			return [sections indexOfObject:existingKey];
		}
	}
	//or insert at the end
	return sections.count;
}

+ (NSArray*)addedSectionsByComparingSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter {
	NSMutableArray *addedSections = [NSMutableArray arrayWithCapacity:sectionsAfter.count];
	for (id key in sectionsAfter) {
		if (![sectionsBefore containsObject:key]) {
			[addedSections addObject:key];
		}
	}
	return addedSections;
}

#pragma mark - deleting

+ (NSIndexSet*)indexOfSectionsToBeRemoved:(NSArray*)sectionsToBeRemoved fromSections:(NSArray*)sections {
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	for (id key in sectionsToBeRemoved) {
		NSUInteger indexInSections = [sections indexOfObject:key];
		[indexSet addIndex:indexInSections];
	}
	return indexSet;
}

+ (NSArray*)removedSectionsByComparingSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter {
	NSMutableArray *removedSections = [NSMutableArray arrayWithCapacity:sectionsBefore.count];
	for (id key in sectionsBefore) {
		if (![sectionsAfter containsObject:key]) {
			[removedSections addObject:key];
		}
	}
	return removedSections;
}

#pragma mark - reloading

+ (NSArray*)commonSectionsInSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter {
	NSIndexSet *indexSet = [sectionsBefore indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
		return [sectionsAfter containsObject:obj];
	}];
	return [sectionsBefore objectsAtIndexes:indexSet];
}

+ (NSIndexSet*)indexOfSectionsThatChanged:(NSArray*)changedSections inSections:(NSArray*)sections {
	NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
	for (id key in changedSections) {
		NSUInteger indexInSections = [sections indexOfObject:key];
		[indexSet addIndex:indexInSections];
	}
	return indexSet;
}

+ (NSArray*)changedSectionsByComparingCellsBefore:(NSDictionary*)sectionsBefore withCellsAfter:(NSDictionary*)sectionsAfter {
	NSAssert(sectionsBefore.count == sectionsAfter.count, @"can only compare changeds, if section count is already balanced");
	NSAssert([sectionsBefore.allKeys isEqualToArray:sectionsAfter.allKeys], @"can only compare changeds, if sections are the same");
	NSMutableArray *changedSections = [NSMutableArray arrayWithCapacity:sectionsAfter.count];
	for (id key in sectionsAfter.allKeys) {
		NSArray *cellsInSectionBefore = sectionsBefore[key];
		NSArray *cellsInSectionAfter = sectionsAfter[key];
		if (![cellsInSectionBefore isEqualToArray:cellsInSectionAfter]) {
			[changedSections addObject:key];
		}
	}
	return changedSections;
}

@end
