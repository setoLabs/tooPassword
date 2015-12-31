//
//  TPWChangedTableSectionsUtilTests.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 06.02.13.
//
//

#import "TPWChangedTableSectionsUtilTests.h"
#import "TPWChangedTableSectionsUtil.h"

@implementation TPWChangedTableSectionsUtilTests

- (void)testAddSectionsToEmptyTable {
	NSArray *sectionsBefore = nil;
	NSArray *sectionsAfter = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *addedSections = [TPWChangedTableSectionsUtil addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"A", @"B", @"C", @"D", @"E"];
	XCTAssertEqualObjects(addedSections, expectedArray, @"added sections must be A-E");
	
	NSIndexSet *indexOfAddedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeAdded:addedSections intoSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)];
	XCTAssertEqualObjects(indexOfAddedSections, expectedIndexes, @"added sections must have indexes 0-4");
}

- (void)testAddSectionsAtEnd {
	NSArray *sectionsBefore = @[@"A", @"B", @"C"];
	NSArray *sectionsAfter = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *addedSections = [TPWChangedTableSectionsUtil addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"D", @"E"];
	XCTAssertEqualObjects(addedSections, expectedArray, @"added sections must be D and E");
	
	NSIndexSet *indexOfAddedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeAdded:addedSections intoSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 2)];
	XCTAssertEqualObjects(indexOfAddedSections, expectedIndexes, @"added sections must have indexes 3 and 4");
}

- (void)testAddSectionsAtBegin {
	NSArray *sectionsBefore = @[@"C", @"D", @"E"];
	NSArray *sectionsAfter = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *addedSections = [TPWChangedTableSectionsUtil addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"A", @"B"];
	XCTAssertEqualObjects(addedSections, expectedArray, @"added sections must be A and B");
	
	NSIndexSet *indexOfAddedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeAdded:addedSections intoSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
	XCTAssertEqualObjects(indexOfAddedSections, expectedIndexes, @"added sections must have indexes 0 and 1");
}

- (void)testAddSectionsInMiddle {
	NSArray *sectionsBefore = @[@"A", @"D", @"E"];
	NSArray *sectionsAfter = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *addedSections = [TPWChangedTableSectionsUtil addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"B", @"C"];
	XCTAssertEqualObjects(addedSections, expectedArray, @"added sections must be B and C");
	
	NSIndexSet *indexOfAddedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeAdded:addedSections intoSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
	XCTAssertEqualObjects(indexOfAddedSections, expectedIndexes, @"added sections must have indexes 1 and 2");
}

- (void)testAddSectionsInTwoRanges {
	NSArray *sectionsBefore = @[@"A", @"D", @"E"];
	NSArray *sectionsAfter = @[@"A", @"B", @"C", @"D", @"E", @"F"];
	NSArray *addedSections = [TPWChangedTableSectionsUtil addedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"B", @"C", @"F"];
	XCTAssertEqualObjects(addedSections, expectedArray, @"added sections must be B and C and F");
	
	NSIndexSet *indexOfAddedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeAdded:addedSections intoSections:sectionsBefore];
	NSMutableIndexSet *expectedIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
	[expectedIndexes addIndex:5];
	XCTAssertEqualObjects(indexOfAddedSections, expectedIndexes, @"added sections must have indexes 1, 2 and 5");
}

#pragma mark - test removing sections

- (void)testRemoveAllSections {
	NSArray *sectionsBefore = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *sectionsAfter = nil;
	NSArray *removedSections = [TPWChangedTableSectionsUtil removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"A", @"B", @"C", @"D", @"E"];
	XCTAssertEqualObjects(removedSections, expectedArray, @"removed sections must be A-E");
	
	NSIndexSet *indexOfRemovedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeRemoved:removedSections fromSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 5)];
	XCTAssertEqualObjects(indexOfRemovedSections, expectedIndexes, @"removed sections must have indexes 0-4");
}

- (void)testRemoveSectionsAtBegin {
	NSArray *sectionsBefore = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *sectionsAfter = @[@"C", @"D", @"E"];
	NSArray *removedSections = [TPWChangedTableSectionsUtil removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"A", @"B"];
	XCTAssertEqualObjects(removedSections, expectedArray, @"removed sections must be A and B");
	
	NSIndexSet *indexOfRemovedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeRemoved:removedSections fromSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
	XCTAssertEqualObjects(indexOfRemovedSections, expectedIndexes, @"removed sections must have indexes 0 and 1");
}

- (void)testRemoveSectionsAtEnd {
	NSArray *sectionsBefore = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *sectionsAfter = @[@"A", @"B", @"C"];
	NSArray *removedSections = [TPWChangedTableSectionsUtil removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"D", @"E"];
	XCTAssertEqualObjects(removedSections, expectedArray, @"removed sections must be B and C and F");
	
	NSIndexSet *indexOfRemovedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeRemoved:removedSections fromSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(3, 2)];
	XCTAssertEqualObjects(indexOfRemovedSections, expectedIndexes, @"removed sections must have indexes 3 and 4");
}

- (void)testRemoveSectionsInMiddle {
	NSArray *sectionsBefore = @[@"A", @"B", @"C", @"D", @"E"];
	NSArray *sectionsAfter = @[@"A", @"D", @"E"];
	NSArray *removedSections = [TPWChangedTableSectionsUtil removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"B", @"C"];
	XCTAssertEqualObjects(removedSections, expectedArray, @"removed sections must be B and C");
	
	NSIndexSet *indexOfRemovedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeRemoved:removedSections fromSections:sectionsBefore];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
	XCTAssertEqualObjects(indexOfRemovedSections, expectedIndexes, @"removed sections must have indexes 2 and 3");
}

- (void)testRemoveSectionsInTwoRanges {
	NSArray *sectionsBefore = @[@"A", @"B", @"C", @"D", @"E", @"F"];
	NSArray *sectionsAfter = @[@"A", @"D", @"E"];
	NSArray *removedSections = [TPWChangedTableSectionsUtil removedSectionsByComparingSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"B", @"C", @"F"];
	XCTAssertEqualObjects(removedSections, expectedArray, @"removed sections must be B and C and F");
	
	NSIndexSet *indexOfRemovedSections = [TPWChangedTableSectionsUtil indexOfSectionsToBeRemoved:removedSections fromSections:sectionsBefore];
	NSMutableIndexSet *expectedIndexes = [NSMutableIndexSet indexSetWithIndexesInRange:NSMakeRange(1, 2)];
	[expectedIndexes addIndex:5];
	XCTAssertEqualObjects(indexOfRemovedSections, expectedIndexes, @"removed sections must have indexes 1, 2 and 5");
}

#pragma mark - test changed sections

- (void)testChangedSections {
	NSDictionary *sectionsBefore = @{@"A": @[@"A", @"B", @"C"], @"B": @[@"A", @"B", @"C"], @"C": @[@"A", @"B", @"C"]};
	NSDictionary *sectionsAfter = @{@"A": @[@"X", @"B", @"C"], @"B": @[@"A", @"B", @"C", @"D"], @"C": @[@"A", @"B", @"C"]};
	NSArray *changedSections = [TPWChangedTableSectionsUtil changedSectionsByComparingCellsBefore:sectionsBefore withCellsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"A", @"B"];
	XCTAssertEqualObjects(changedSections, expectedArray, @"removed sections must be B and C and F");
	
	NSIndexSet *indexOfChangedSections = [TPWChangedTableSectionsUtil indexOfSectionsThatChanged:changedSections inSections:sectionsAfter.allKeys];
	NSIndexSet *expectedIndexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)];
	XCTAssertEqualObjects(indexOfChangedSections, expectedIndexes, @"removed sections must have indexes 1 and 2");
}

- (void)testFindingCommonSections {
	NSArray *sectionsBefore = @[@"A", @"B", @"C"];
	NSArray *sectionsAfter = @[@"B", @"C", @"D"];
	NSArray *commonSections = [TPWChangedTableSectionsUtil commonSectionsInSectionsBefore:sectionsBefore withSectionsAfter:sectionsAfter];
	NSArray *expectedArray = @[@"B", @"C"];
	XCTAssertEqualObjects(commonSections, expectedArray, @"added sections must be B and C");

}

@end
