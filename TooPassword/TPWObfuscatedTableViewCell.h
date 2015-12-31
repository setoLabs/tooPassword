//
//  TPWObfuscatedTableViewCell.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 18.10.13.
//
//

#import "TPWGroupedTableViewCell.h"

extern NSString *const kTPWObfuscatedTableViewCellIdentifier;

typedef void(^TPWObfuscatedTableViewCellChangedBlock)(BOOL obfuscated);

@interface TPWObfuscatedTableViewCell : TPWGroupedTableViewCell

@property (nonatomic, copy) TPWObfuscatedTableViewCellChangedBlock changedBlock;
@property (nonatomic, assign, getter = isObfuscated) BOOL obfuscated;

- (void)revealAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
