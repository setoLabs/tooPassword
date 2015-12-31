//
//  TPWSectionFooterView.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 02.02.13.
//
//

#import "TPWSectionFooterView.h"
#import "TPWiOSVersions.h"
#import "UIColor+TPWColors.h"

CGFloat const kTPWSectionFooterViewHeight = 4.0;

@implementation TPWSectionFooterView

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor tpwTableViewCellColor];
	}
	return self;
}

@end
