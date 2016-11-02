//
//  XXEditorFontSizeView.h
//  XXTouchApp
//
//  Created by Zheng on 02/11/2016.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_FONT_SIZE 24
#define MIN_FONT_SIZE 10

@class XXEditorFontSizeView;

@protocol XXEditorFontSizeViewDelegate <NSObject>
- (void)fontViewSizeDidChanged:(XXEditorFontSizeView *)view;

@end

@interface XXEditorFontSizeView : UIView
@property (nonatomic, assign) NSUInteger fontSize;
@property (nonatomic, weak) id<XXEditorFontSizeViewDelegate> delegate;

@end
