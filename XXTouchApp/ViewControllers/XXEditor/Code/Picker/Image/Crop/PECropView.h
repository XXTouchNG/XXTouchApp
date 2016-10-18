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
    kPECropViewTypeRect = 0,
    kPECropViewTypePosition = 1
} kPECropViewType;

@interface PECropView : UIView

@property (nonatomic, assign) kPECropViewType type;

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

- (void)resetCropRect;
- (void)resetCropRectAnimated:(BOOL)animated;

- (void)setRotationAngle:(CGFloat)rotationAngle snap:(BOOL)snap;
- (void)rotateLeft;
- (void)rotateRight;

@end
