//
//  TPWSearchBar.h
//  TooPassword
//
//  Created by Sebastian Stenzel on 26.01.13.
//
//

#import <UIKit/UIKit.h>

@interface TPWSearchBar : UISearchBar

- (void)willBeginSearchAnimated:(BOOL)animated;
- (void)willEndSearchAnimated:(BOOL)animated;

@end
