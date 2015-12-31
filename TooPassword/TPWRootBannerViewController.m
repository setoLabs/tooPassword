//
//  TPWRootBannerViewController.m
//  TooPassword
//
//  Created by Tobias Hagemann on 12/02/14.
//
//

#import "TPWRootBannerViewController.h"

@interface TPWRootBannerViewController ()
@property (nonatomic, strong) UIViewController *childController;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@end

@implementation TPWRootBannerViewController

- (instancetype)initWithChildController:(UIViewController *)childController {
	if (self = [super initWithNibName:nil bundle:nil]) {
		self.childController = childController;
		[self addChildViewController:childController];
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.childController.view.frame = self.containerView.bounds;
	[self.view addSubview:self.childController.view];
	[self.childController didMoveToParentViewController:self];
}

@end
