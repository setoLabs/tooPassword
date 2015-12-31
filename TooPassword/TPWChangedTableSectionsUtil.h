//
//  TPWChangedTableSectionsUtil.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 06.02.13.
//
//

#import <Foundation/Foundation.h>

@interface TPWChangedTableSectionsUtil : NSObject

+ (void)updateTable:(UITableView*)tableView byComparingSectionsBefore:(NSArray*)sectionsBefore cellsBefore:(NSDictionary*)cellsBefore withSectionsAfter:(NSArray*)sectionsAfter cellsAfter:(NSDictionary*)cellsAfter;

#pragma mark - public for unit testing:

//adding
+ (NSIndexSet*)indexOfSectionsToBeAdded:(NSArray*)sectionsToBeAdded intoSections:(NSArray*)sections;
+ (NSArray*)addedSectionsByComparingSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter;

//removing
+ (NSIndexSet*)indexOfSectionsToBeRemoved:(NSArray*)sectionsToBeRemoved fromSections:(NSArray*)sections;
+ (NSArray*)removedSectionsByComparingSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter;

//changing
+ (NSArray*)commonSectionsInSectionsBefore:(NSArray*)sectionsBefore withSectionsAfter:(NSArray*)sectionsAfter;
+ (NSIndexSet*)indexOfSectionsThatChanged:(NSArray*)changedSections inSections:(NSArray*)sections;
+ (NSArray*)changedSectionsByComparingCellsBefore:(NSDictionary*)sectionsBefore withCellsAfter:(NSDictionary*)sectionsAfter;

@end
