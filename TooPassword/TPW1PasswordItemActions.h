//
//  TPW1PasswordItemActions.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 03.02.13.
//
//

#import <Foundation/Foundation.h>

typedef void(^TPWActionSheetButtonPressedBlock)();

extern NSTextCheckingTypes const kTPWItemActionDataDetectorTypes;

@interface TPW1PasswordItemActions : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *dataDetectorMatches;
@property (nonatomic, assign) BOOL showsTextInActionSheet;
@property (nonatomic, copy) TPWActionSheetButtonPressedBlock pressedRevealButtonFeedback;
@property (nonatomic, copy) TPWActionSheetButtonPressedBlock pressedHideButtonFeedback;

- (id)initWithActionsForText:(NSString*)text;
- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes;
- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes onReveal:(TPWActionSheetButtonPressedBlock)revealFeedback;
- (id)initWithActionsForText:(NSString*)text dataDetectorTypes:(NSTextCheckingTypes)detectorTypes onHide:(TPWActionSheetButtonPressedBlock)hideFeedback;
- (UIActionSheet*)actionSheetWithDelegate:(id<UIActionSheetDelegate>)delegate;

#pragma mark - invoking actions

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
