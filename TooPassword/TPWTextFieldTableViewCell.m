//
//  TPWTextFieldTableViewCell.m
//  TooPassword
//
//  Created by Sebastian Stenzel on 15.11.13.
//
//

#import "TPWTextFieldTableViewCell.h"
#import "TPWiOSVersions.h"

@implementation TPWTextFieldTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
		self.textField.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		self.textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
		[self.contentView addSubview:self.textField];
	}
	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	CGFloat leftMargin = [TPWiOSVersions isGreaterThanOrEqualToVersion:@"7.0"] ? 15.0 : 10.0;
	
	self.textField.frame = CGRectMake(leftMargin, 0.0, self.contentView.bounds.size.width - leftMargin, self.contentView.bounds.size.height);
}

- (void)prepareForReuse {
	self.textField.text = nil;
	self.textField.placeholder = nil;
	self.textField.keyboardType = UIKeyboardTypeDefault;
	self.textField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
	self.textField.autocorrectionType = UITextAutocorrectionTypeDefault;
	self.textField.secureTextEntry = NO;
	self.textField.delegate = nil;
}

@end
