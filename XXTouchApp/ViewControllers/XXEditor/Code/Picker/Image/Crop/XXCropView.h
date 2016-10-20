//
//  PECropView.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>

typedef enum : NSUInteger {
    kXXCropViewTypeRect = 0,
    kXXCropViewTypePosition = 1,
    kXXCropViewTypeColor = 2,
    kXXCropViewTypePositionColor = 3,
    kXXCropViewTypeMultiplePositionColor = 4,
} kXXCropViewType;

@interface XXCropView : UIView

@property (nonatomic, assign) kXXCropViewType type;

@property (nonatomic) UIImage *image;
@property (nonatomic, readonly) UIImage *croppedImage;
@property (nonatomic, readonly) CGRect zoomedCropRect;
@property (nonatomic, readonly) CGAffineTransform rotation;
@property (nonatomic, readonly) BOOL userHasModifiedCropArea;

@property (nonatomic) BOOL allowsRotate;
@property (nonatomic) BOOL keepingCropAspectRatio;
@property (nonatomic) BOOL allowsOperation;
@property (nonatomic) CGFloat cropAspectRatio;

@property (nonatomic) CGRect cropRect;
@property (nonatomic) CGRect imageCropRect;
@property (nonatomic) CGFloat rotationAngle;

- (instancetype)initWithFrame:(CGRect)frame andType:(kXXCropViewType)type;

- (void)resetCropRect;
- (void)resetCropRectAnimated:(BOOL)animated;

- (void)setRotationAngle:(CGFloat)rotationAngle snap:(BOOL)snap;
- (void)rotateLeft;
- (void)rotateRight;

@end
