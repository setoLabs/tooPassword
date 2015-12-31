//
//  TPW1PasswordDataStructure.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 12.01.13.
//
//

#import "NSData+Base64.h"
#import "UIFont+TPWFonts.h"
#import "TPWiOSVersions.h"
#import "TPWSettings.h"

#import "TPW1PasswordItem.h"
#import "TPW1PasswordItemHeaderView.h"
#import "TPWObfuscatedTableViewCell.h"

CGFloat const kTPW1PasswordItemMaximumRowHeight = 2009; //"tableView:heightForRowAtIndexPath: Due to an underlying implementation detail, you should not return values greater than 2009."
NSString *const kTPW1PasswordItemDefaultSecurityLevel = @"SL5";
NSString *const kTPW1PasswordItemJsonKeyNotesPlain = @"notesPlain";

NSString *const kTPW1PasswordItemJsonKeyTitle = @"title";
NSString *const kTPW1PasswordItemJsonKeyOpenContents = @"openContents";
NSString *const kTPW1PasswordItemJsonKeySecurityLevel = @"securityLevel";
NSString *const kTPW1PasswordItemJsonKeyTypeName = @"typeName";
NSString *const kTPW1PasswordItemJsonKeyEncrypted = @"encrypted";
NSString *const kTPW1PasswordItemJsonKeyLocation = @"location";
NSString *const kTPW1PasswordItemJsonKeyUuid = @"uuid";

@interface TPW1PasswordItem ()
@property (nonatomic, strong) TPW1PasswordType *type;
@end

@implementation TPW1PasswordItem

- (id)init {
	if (self = [super init]) {
		self.notesFont = [UIFont tpwDefaultFont];
	}
	return self;
}

#pragma mark - searching

- (BOOL)matchesSearchTerm:(NSString*)word searchTitleOnly:(BOOL)simpleSearch {
	return (self.title && [self.title rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound)
		|| (self.location && [self.location rangeOfString:word options:NSCaseInsensitiveSearch].location != NSNotFound);
}

#pragma mark - decrypting

- (void)decryptByAcceptingDecryptor:(TPWDecryptor*)decryptor {
	if (!self.encrypted) return; //nothing to decrypt
	if (!self.securityLevel) return; //no security level specified
	
	//decrypt:
	NSData *decrypted = [decryptor decryptData:self.encrypted withSecurityLevel:self.securityLevel];
	if (!decrypted) return;
	
	//parse json:
	NSError *error;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:decrypted options:0 error:&error];
	if (error != nil) {
		DLog(@"unable to parse json: %@", [[NSString alloc] initWithData:decrypted encoding:NSUTF8StringEncoding]);
		return;
	} else {
		[self didDecrypt:dict];
		[self determineIndexesOfPasswordRows];
	}
}

- (void)didDecrypt:(NSDictionary*)decrypted {
	self.notesPlain = decrypted[kTPW1PasswordItemJsonKeyNotesPlain];
}

#pragma mark - hash/isEqual

- (NSUInteger)hash {
	return self.uuid.hash;
}

- (BOOL)isEqual:(id)object {
	if ([object isKindOfClass:TPW1PasswordItem.class]) {
		TPW1PasswordItem *other = (TPW1PasswordItem*)object;
		return [self.uuid isEqualToString:other.uuid] && [self.encrypted isEqualToData:other.encrypted];
	}
	return NO;
}

#pragma mark - obfuscation of cells

- (void)determineIndexesOfPasswordRows {
	self.indexesOfPasswordRows = [NSMutableIndexSet indexSet];
}

- (void)determineIndexesOfObfuscatedRows {
	self.indexesOfObfuscatedRows = [NSMutableIndexSet indexSet];
	if ([TPWSettings concealPasswords]) {
		[self.indexesOfObfuscatedRows addIndexes:self.indexesOfPasswordRows];
	}
}

- (BOOL)isPasswordCellAtIndexPath:(NSIndexPath*)indexPath {
	return [self.indexesOfPasswordRows containsIndex:indexPath.row];
}

- (BOOL)isObfuscatedCellAtIndexPath:(NSIndexPath*)indexPath {
	return [self.indexesOfObfuscatedRows containsIndex:indexPath.row];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSAssert(false, @"to be overwritten by subclasses"); //can not be called, if tableView:numberOfRowsInSection: is not also overwritten.
	return nil;
}

- (NSString*)titleForHeaderInSection:(NSUInteger)section inTableView:(UITableView *)tableView {
	return nil;
}

- (CGFloat)preferredHeightForHeaderInSection:(NSUInteger)section inTableView:(UITableView *)tableView {
	if ([self titleForHeaderInSection:section inTableView:tableView]) {
		UIView *headerView = [self preferredViewForHeaderInSection:section inTableView:tableView];
		[headerView layoutIfNeeded];
		UILabel *label = [headerView.subviews firstObject];
		CGFloat offset = (section == 0) ? 32.0 : 12.0;
		return CGRectGetHeight(label.frame) + offset;
	}
	return 0.0;
}

- (CGFloat)preferredHeightForFooterInSection:(NSUInteger)section inTableView:(UITableView*)tableView {
	return 0.0;
}

- (UIView*)preferredViewForHeaderInSection:(NSUInteger)section inTableView:(UITableView*)tableView {
	NSString *title = [self titleForHeaderInSection:section inTableView:tableView];
	if (!title) {
		return nil;
	}
	return [[TPW1PasswordItemHeaderView alloc] initWithTitle:title section:section];
}

- (UIView*)preferredViewForFooterInSection:(NSUInteger)section inTableView:(UITableView*)tableView {
	return nil;
}

- (CGFloat)preferredHeightForRowAtIndexPath:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView {
	return tableView.rowHeight;
}

- (CGFloat)preferredHeightForNotesRowInTableView:(UITableView *)tableView {
	CGFloat labelWidth;
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		labelWidth = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? 290.0 : 280.0; //iPhone portrait
	} else if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
		labelWidth = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? 417.0 : 365.0; //iPad portrait
	} else if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		labelWidth = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? 673.0 : 597.0; //iPad landscape
	} else {
		labelWidth = 0.0; //will not happen, as all cases are covered by previous statements
	}
	
	CGSize textSize = [self.notesPlain sizeWithFont:self.notesFont constrainedToSize:CGSizeMake(labelWidth, kTPW1PasswordItemMaximumRowHeight) lineBreakMode:NSLineBreakByWordWrapping];
	return textSize.height + 20.0; //10px margin top and bottom
}

- (UITableViewCell *)cellForNotesRowInTableView:(UITableView*)tableView {
	//load cell:
	static NSString *CellIdentifier = @"TPW1PasswordItemSecureNotesCell";
	TPWGroupedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[TPWGroupedTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = self.notesFont;
		cell.textLabel.numberOfLines = 0;
	}
	
	//configure cell:
	cell.position = TPWCellBackgroundViewPositionSingle;
	cell.textLabel.text = self.notesPlain;
	
	return cell;
}

- (TPW1PasswordItemActions*)actionsForRowInTable:(UITableView*)tableView atIndexPath:(NSIndexPath*)indexPath {
	return [[TPW1PasswordItemActions alloc] initWithActionsForText:nil];
}

#pragma mark - lifecycle

- (id)initWithJson:(NSData*)jsonData {
	if (self = [self init]) { //yes, I really mean [self init], so subclasses can overwrite init
		NSError *error;
		NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
		
		if (error) {
			DLog(@"error during decoding of json %@\n error: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], error);
			return nil;
		}
		
		self.title = dict[kTPW1PasswordItemJsonKeyTitle];
		self.openContents = dict[kTPW1PasswordItemJsonKeyOpenContents];
		self.typeName = dict[kTPW1PasswordItemJsonKeyTypeName];
		self.encrypted = [NSData dataWithBase64Representation:dict[kTPW1PasswordItemJsonKeyEncrypted]];
		self.securityLevel = dict[kTPW1PasswordItemJsonKeySecurityLevel] ? : self.openContents[kTPW1PasswordItemJsonKeySecurityLevel] ? : kTPW1PasswordItemDefaultSecurityLevel;
		self.location = dict[kTPW1PasswordItemJsonKeyLocation];
		self.uuid = dict[kTPW1PasswordItemJsonKeyUuid];
	}
	return self;
}

+ (TPW1PasswordItem*)itemWithJson:(NSData*)jsonData {
	NSError *error;
	NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
	
	if (error) {
		DLog(@"error during decoding of json %@\n error: %@", [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding], error);
		return nil;
	}
	
	//try to find matching classes
	NSString *typeName = dict[kTPW1PasswordItemJsonKeyTypeName];
	TPW1PasswordType *type = [TPW1PasswordType bestMatchingTypeWithName:typeName];
	TPW1PasswordItem *item = [[type.classRepresentingType alloc] initWithJson:jsonData];
	item.type = type;
	return item;
}

@end
