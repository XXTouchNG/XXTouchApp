//
//  PECropRectView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/21.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    kPEResizeControlPositionTopLeft = 0,
    kPEResizeControlPositionTopRight,
    kPEResizeControlPositionBottomLeft,
    kPEResizeControlPositionBottomRight
} kPEResizeControlPosition;

@protocol PECropRectViewDelegate;

@interface PECropRectView : UIView

@property (nonatomic, weak) id<PECropRectViewDelegate> delegate;
@property (nonatomic, assign) BOOL showsGridMajor;
@property (nonatomic, assign) BOOL showsGridMinor;
@property (nonatomic, assign) kPEResizeControlPosition resizeControlPosition;

@property (nonatomic, assign) BOOL keepingAspectRatio;

@end

@protocol PECropRectViewDelegate <NSObject>

- (void)cropRectViewDidBeginEditing:(PECropRectView *)cropRectView;
- (void)cropRectViewEditingChanged:(PECropRectView *)cropRectView;
- (void)cropRectViewDidEndEditing:(PECropRectView *)cropRectView;

@end

