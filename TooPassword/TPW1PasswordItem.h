//
//  TPW1PasswordDataStructure.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 12.01.13.
//
//

#import <Foundation/Foundation.h>
#import "TPWDecryptor.h"
#import "TPW1PasswordType.h"
#import "TPW1PasswordItemActions.h"

extern CGFloat const kTPW1PasswordItemMaximumRowHeight;
extern NSString *const kTPW1PasswordItemDefaultSecurityLevel;
extern NSString *const kTPW1PasswordItemJsonKeyNotesPlain;

/**
 ObjC-representation of one single .1password file.
 */
@interface TPW1PasswordItem : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSDictionary *openContents;
@property (nonatomic, strong) NSString *typeName;
@property (nonatomic, strong) NSData *encrypted;
@property (nonatomic, strong) NSString *securityLevel;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSString *uuid;

@property (nonatomic, readonly) TPW1PasswordType *type;
@property (nonatomic, strong) NSMutableIndexSet *indexesOfPasswordRows;
@property (nonatomic, strong) NSMutableIndexSet *indexesOfObfuscatedRows;

@property (nonatomic, strong) UIFont *notesFont;
@property (nonatomic, strong) NSString *notesPlain;

- (BOOL)matchesSearchTerm:(NSString*)word searchTitleOnly:(BOOL)simpleSearch;

- (void)decryptByAcceptingDecryptor:(TPWDecryptor*)decryptor; //visitor pattern
- (void)didDecrypt:(NSDictionary*)decrypted;

- (void)determineIndexesOfPasswordRows;
- (void)determineIndexesOfObfuscatedRows;
- (BOOL)isPasswordCellAtIndexPath:(NSIndexPath*)indexPath;
- (BOOL)isObfuscatedCellAtIndexPath:(NSIndexPath*)indexPath;

+ (TPW1PasswordItem*)itemWithJson:(NSData*)jsonData;

//tableview stuff
- (NSString*)titleForHeaderInSection:(NSUInteger)section inTableView:(UITableView *)tableView;
- (CGFloat)preferredHeightForHeaderInSection:(NSUInteger)section inTableView:(UITableView *)tableView;
- (CGFloat)preferredHeightForFooterInSection:(NSUInteger)section inTableView:(UITableView*)tableView;
- (UIView*)preferredViewForHeaderInSection:(NSUInteger)section inTableView:(UITableView*)tableView;
- (UIView*)preferredViewForFooterInSection:(NSUInteger)section inTableView:(UITableView*)tableView;
- (CGFloat)preferredHeightForRowAtIndexPath:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView;
- (CGFloat)preferredHeightForNotesRowInTableView:(UITableView *)tableView;
- (UITableViewCell *)cellForNotesRowInTableView:(UITableView*)tableView;
- (TPW1PasswordItemActions*)actionsForRowInTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath;

@end
