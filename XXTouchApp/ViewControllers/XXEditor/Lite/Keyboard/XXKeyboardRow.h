//
//  XXKeyboardRow.h
//  XXTouchApp
//
//  Created by Zheng on 9/19/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, XXKeyboardButtonStyle) {
    XXKeyboardButtonStylePhone,
    XXKeyboardButtonStyleTablet
};

@interface XXKeyboardRow : UIInputView
@property (nonatomic, assign) XXKeyboardButtonStyle style;
- (instancetype)initWithTextView:(UITextView *)textView;

@end
