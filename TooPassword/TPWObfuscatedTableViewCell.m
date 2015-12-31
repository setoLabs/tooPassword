//
//  TPWObfuscatedTableViewCell.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 18.10.13.
//
//

#import "TPWObfuscatedTableViewCell.h"
#import "TPWiOSVersions.h"
#import "UIFont+TPWFonts.h"
#import "UIColor+TPWColors.h"
#import "TPWTouchTransparentScrollView.h"
#import "TPWSettings.h"

NSString *const kTPWObfuscatedTableViewCellIdentifier = @"TPWObfuscatedTableViewCellIdentifier";
NSString *const kTPWObfuscatedTableViewCellBullets = @"••••••••";

@interface TPWObfuscatedTableViewCell () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UILabel *bulletsLabel;
@end

@implementation TPWObfuscatedTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.obfuscated = [TPWSettings concealPasswords];
		
		// detailTextLabel
		self.detailTextLabel.font = [UIFont tpwMonospaceFont];
		
		// scrollView
		self.scrollView = [[TPWTouchTransparentScrollView alloc] initWithFrame:CGRectZero];
		self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.scrollView.showsHorizontalScrollIndicator = NO;
		self.scrollView.bounces = NO;
		self.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
		self.scrollView.delegate = self;
		[self.contentView addSubview:self.scrollView];
		
		// bulletsLabel
		self.bulletsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		self.bulletsLabel.textColor = [UIColor tpwTextColor];
		self.bulletsLabel.font = [UIFont tpwMonospaceFont];
		self.bulletsLabel.text = kTPWObfuscatedTableViewCellBullets;
		[self.scrollView addSubview:self.bulletsLabel];
		
		// bring textLabel to front
		[self.contentView bringSubviewToFront:self.textLabel];
		self.textLabel.userInteractionEnabled = NO;
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat cellPadding = [TPWiOSVersions isLessThanVersion:@"7.0"] ? 10.0 : 15.0;
	
	// scrollview
	self.scrollView.frame = self.contentView.bounds;
	
	// kidnap detailTextLabel
	[self.detailTextLabel removeFromSuperview];
	[self.scrollView addSubview:self.detailTextLabel];
	
	// detailTextLabel on the very right
	CGFloat width = CGRectGetWidth(self.contentView.bounds) + CGRectGetWidth(self.detailTextLabel.frame);
	self.scrollView.contentSize = CGSizeMake(width+cellPadding, CGRectGetHeight(self.contentView.bounds));
	self.detailTextLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds), CGRectGetMinY(self.detailTextLabel.frame),
											CGRectGetWidth(self.detailTextLabel.frame), CGRectGetHeight(self.detailTextLabel.frame));
	
	// bullets on the "visible" right
	[self.bulletsLabel sizeToFit];
	self.bulletsLabel.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.bulletsLabel.frame) - cellPadding, CGRectGetMinY(self.detailTextLabel.frame),
										 CGRectGetWidth(self.bulletsLabel.frame), CGRectGetHeight(self.bulletsLabel.frame));
	
	// adjust scroll position
	CGFloat maxOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
	CGFloat minOffset = 0.0;
	CGFloat offset = (self.obfuscated) ? minOffset : maxOffset;
	self.scrollView.contentOffset = CGPointMake(offset, 0.0);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	CGFloat scrollOffset = scrollView.contentOffset.x;
	CGFloat fullRevealedOriginXOfBullets = CGRectGetMinX(self.bulletsLabel.frame) - (scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds));
	
	CGFloat maxOffset;
	if (fullRevealedOriginXOfBullets < CGRectGetMaxX(self.textLabel.frame)) {
		// bullets need to be hidden when arriving at textLabel
		maxOffset = CGRectGetMinX(self.bulletsLabel.frame) - CGRectGetMaxX(self.textLabel.frame);
	} else {
		// bullets need to be hidden when fully scrolled to the left
		maxOffset = scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds);
	}
	
	CGFloat alphaProgress = scrollOffset / maxOffset;
	self.bulletsLabel.alpha = MIN(1.0 - alphaProgress, 1.0);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
	if ([TPWiOSVersions isLessThanVersion:@"6.0"]) {
		// iOS 5 doesn't react to targetContentOffset at all, buggy shit :(
		// workaround using scrollViewDidEndDragging:willDecelerate: and scrollViewDidEndDecelerating:
		return;
	}
	
	CGFloat maxOffset = scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds);
	CGFloat minOffset = 0.0;
	CGFloat scrollOffset = scrollView.contentOffset.x;
	CGFloat scrollProgress = scrollOffset / maxOffset;
	if (velocity.x > 0) {
		// reveal password
		self.obfuscated = NO;
		targetContentOffset->x = maxOffset;
	} else if (velocity.x < 0) {
		// hide password
		self.obfuscated = YES;
		targetContentOffset->x = minOffset;
	} else if (scrollProgress > 0.5) {
		// reveal password
		self.obfuscated = NO;
		targetContentOffset->x = maxOffset;
	} else {
		// hide password
		self.obfuscated = YES;
		targetContentOffset->x = minOffset;
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"6.0"]) {
		// this is only a workaround for iOS 5
		return;
	}
	
	if (!decelerate) {
		CGFloat maxOffset = scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds);
		CGFloat scrollOffset = scrollView.contentOffset.x;
		CGFloat scrollProgress = scrollOffset / maxOffset;
		if (scrollProgress > 0.5) {
			[self revealAnimated:YES];
		} else {
			[self hideAnimated:YES];
		}
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	if ([TPWiOSVersions isGreaterThanOrEqualToVersion:@"6.0"]) {
		// this is only a workaround for iOS 5
		return;
	}
	
	CGFloat maxOffset = scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds);
	CGFloat scrollOffset = scrollView.contentOffset.x;
	CGFloat scrollProgress = scrollOffset / maxOffset;
	if (scrollProgress > 0.5) {
		[self revealAnimated:YES];
	} else {
		[self hideAnimated:YES];
	}
}

#pragma mark - obfuscation state

- (void)prepareForReuse {
	self.changedBlock = nil;
	self.obfuscated = [TPWSettings concealPasswords];
}

- (void)setObfuscated:(BOOL)obfuscated {
	BOOL change = _obfuscated != obfuscated;
	_obfuscated = obfuscated;
	if (change && self.changedBlock) {
		self.changedBlock(obfuscated);
	}
}

- (void)revealAnimated:(BOOL)animated {
	self.obfuscated = NO;
	CGFloat maxOffset = self.scrollView.contentSize.width - CGRectGetWidth(self.scrollView.bounds);
	[self.scrollView setContentOffset:CGPointMake(maxOffset, 0.0) animated:animated];
}

- (void)hideAnimated:(BOOL)animated {
	self.obfuscated = YES;
	[self.scrollView setContentOffset:CGPointZero animated:animated];
}

@end
