//
//  PEResizeControl.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol XXResizeControlViewDelegate;

@interface XXResizeControl : UIView

@property (nonatomic, weak) id<XXResizeControlViewDelegate> delegate;
@property (nonatomic, readonly) CGPoint translation;

@end

@protocol XXResizeControlViewDelegate <NSObject>

- (void)resizeControlViewDidBeginResizing:(XXResizeControl *)resizeControlView;
- (void)resizeControlViewDidResize:(XXResizeControl *)resizeControlView;
- (void)resizeControlViewDidEndResizing:(XXResizeControl *)resizeControlView;

@end
