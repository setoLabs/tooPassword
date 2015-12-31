//
//  TPWGroupedTableViewCell.h
//  TooPassword
//
//  Created by Tobias Hagemann on 1/28/13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
	TPWCellBackgroundViewPositionSingle,
	TPWCellBackgroundViewPositionTop,
	TPWCellBackgroundViewPositionMiddle,
	TPWCellBackgroundViewPositionBottom
} TPWCellBackgroundViewPosition;

@interface TPWGroupedTableViewCell : UITableViewCell

@property (nonatomic, assign) TPWCellBackgroundViewPosition position;

@end
