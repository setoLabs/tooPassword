//
//  TPWActionSheet.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 05.02.13.
//
//

#import <UIKit/UIKit.h>

typedef enum {
	kTPWActionSheetActionAddress = 'a',
	kTPWActionSheetActionCopy = 'c',
	kTPWActionSheetActionEmail = 'e',
	kTPWActionSheetActionGetFullVersion = 'g',
	kTPWActionSheetActionHide = 'h',
	kTPWActionSheetActionPhone = 'p',
	kTPWActionSheetActionReveal = 'r',
	kTPWActionSheetActionWeblink = 'w',
	kTPWActionSheetActionUndefined = ' '
} TPWActionSheetActions;

@interface TPWActionSheet : UIActionSheet

@end
