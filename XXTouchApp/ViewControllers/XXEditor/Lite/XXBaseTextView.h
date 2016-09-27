//
//  XXBaseTextView.h
//  XXTouchApp
//
//  Created by Zheng on 9/19/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import "CYRTextView.h"

@interface XXBaseTextView : CYRTextView
@property (nonatomic, assign) BOOL highlightLuaSymbols;
@property (nonatomic, strong) UIFont *defaultFont;
@property (nonatomic, strong) UIFont *boldFont;
@property (nonatomic, strong) UIFont *italicFont;

@end
