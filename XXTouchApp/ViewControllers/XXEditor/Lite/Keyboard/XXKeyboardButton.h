//
//  XXKeyboardButton.h
//  XXTouchApp
//
//  Created by Zheng on 9/19/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XXKeyboardRow.h"

typedef NS_ENUM(NSUInteger, XXKeyboardButtonPosition) {
    XXKeyboardButtonPositionLeft,
    XXKeyboardButtonPositionInner,
    XXKeyboardButtonPositionRight,
    XXKeyboardButtonPositionCount
};

@interface XXKeyboardButton : UIControl
@property (nonatomic, assign) XXKeyboardButtonStyle style;
@property (nonatomic, readonly) XXKeyboardButtonPosition position;
@property (nonatomic, copy) NSString *input;
@property (nonatomic, copy) NSString *output;
@property (nonatomic, weak) id<UITextInput> textInput;
@property (nonatomic, assign) BOOL selecting;

@end
