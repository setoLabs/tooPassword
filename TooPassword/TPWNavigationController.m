//
//  TPWNavigationController.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 31.01.14.
//
//

#import "TPWNavigationController.h"
#import "TPWHighlightLine.h"

@interface TPWNavigationController ()
@property (nonatomic, strong) TPWHighlightLine *orangeHighlightLine;
@end

@implementation TPWNavigationController

- (void)viewDidLoad {
	[super viewDidLoad];
	self.orangeHighlightLine = [[TPWHighlightLine alloc] initWithFrame:CGRectZero];
	[self.navigationBar addSubview:self.orangeHighlightLine];
}

- (void)viewDidUnload {
	[self.orangeHighlightLine removeFromSuperview];
	[super viewDidUnload];
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	CGRect frame = self.navigationBar.frame;
	self.orangeHighlightLine.frame = CGRectMake(0.0, CGRectGetHeight(frame) - 1.0, CGRectGetWidth(frame), 1.0);
}

@end
