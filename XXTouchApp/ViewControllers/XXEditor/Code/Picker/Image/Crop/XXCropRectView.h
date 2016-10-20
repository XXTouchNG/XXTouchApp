//
//  PECropRectView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kXXResizeControlPositionTopLeft = 0,
    kXXResizeControlPositionTopRight,
    kXXResizeControlPositionBottomLeft,
    kXXResizeControlPositionBottomRight
} kXXResizeControlPosition;

@protocol XXCropRectViewDelegate;

@interface XXCropRectView : UIView

@property (nonatomic, weak) id<XXCropRectViewDelegate> delegate;
@property (nonatomic, assign) BOOL showsGridMajor;
@property (nonatomic, assign) BOOL showsGridMinor;
@property (nonatomic, assign) kXXResizeControlPosition resizeControlPosition;

@property (nonatomic, assign) BOOL keepingAspectRatio;

@end

@protocol XXCropRectViewDelegate <NSObject>

- (void)cropRectViewDidBeginEditing:(XXCropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(XXCropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(XXCropRectView *)cropRectView;

@end

