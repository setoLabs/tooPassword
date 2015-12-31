//
//  TPWItemListTableView.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 01.02.13.
//
//

#import "TPWItemListTableView.h"

@implementation TPWItemListTableView

- (void)layoutSubviews {
	[super layoutSubviews];
	
	//lock table header view to top, when scrolling
	CGRect rect = self.tableHeaderView.frame;
	rect.origin.y = MIN(0.0, self.contentOffset.y);
	self.tableHeaderView.frame = rect;
	
	//shitty view from iOS 7 is shitty
	for (UIView *subview in self.subviews) {
		if ([subview isMemberOfClass:UIView.class]) {
			subview.backgroundColor = [UIColor clearColor];
		}
	}
}

@end
