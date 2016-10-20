//
//  PECropView.m
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import "XXCropView.h"
#import "XXCropRectView.h"
#import "UIImage+XXCrop.h"
#import <QuartzCore/QuartzCore.h>
#import "XXImagePickerPixelPreview.h"
#import "XXRectPickerController.h"
#import "XXPositionPickerController.h"
#import "XXColorPickerController.h"
#import "XXPosColorPickerController.h"
#import "XXImageFlagView.h"

static const CGFloat MarginTop = 81.f;
//static const CGFloat MarginBottom = 37.f;
static const CGFloat MarginLeft = 37.f;
//static const CGFloat MarginRight = MarginLeft;

@interface XXCropView ()
<
UIScrollViewDelegate,
UIGestureRecognizerDelegate,
XXCropRectViewDelegate
>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIView *zoomingView;
@property (nonatomic) UIView *maskFlagView;
@property (nonatomic) UIImageView *imageView;

@property (nonatomic) XXCropRectView *cropRectView;
@property (nonatomic) UIView *topOverlayView;
@property (nonatomic) UIView *leftOverlayView;
@property (nonatomic) UIView *rightOverlayView;
@property (nonatomic) UIView *bottomOverlayView;

@property (nonatomic) CGRect insetRect;
@property (nonatomic) CGRect editingRect;

@property (nonatomic, getter = isResizing) BOOL resizing;
@property (nonatomic) UIInterfaceOrientation interfaceOrientation;
@property (nonatomic, strong) UIRotationGestureRecognizer *rotationGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *panGestureRecognizer;

@property (nonatomic, strong) XXImagePickerPixelPreview *imagePreview;
@property (nonatomic, assign) CGPoint lastPoint;
@property (nonatomic, strong) NSMutableArray <XXImageFlagView *> *flagViews;

@end

@implementation XXCropView {
    NSUInteger lastPreviewCorner;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame andType:(kXXCropViewType)type
{
    if (self = [super initWithFrame:frame]) {
        [self commonInitWithType:type];
    }
    
    return self;
}

- (void)commonInitWithType:(kXXCropViewType)type
{
    self.type = type;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"crop-pattern"]];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.maximumZoomScale = 1000.f;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.bounces = NO;
    self.scrollView.bouncesZoom = NO;
    self.scrollView.clipsToBounds = NO;
    [self addSubview:self.scrollView];
    
    self.rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotation:)];
    self.rotationGestureRecognizer.delegate = self;
    self.rotationGestureRecognizer.enabled = self.allowsRotate;
    [self.scrollView addGestureRecognizer:self.rotationGestureRecognizer];
    
    if (self.type == kXXCropViewTypeRect) {
        self.cropRectView = [[XXCropRectView alloc] init];
        self.cropRectView.delegate = self;
        [self addSubview:self.cropRectView];
        
        self.topOverlayView = [[UIView alloc] init];
        self.topOverlayView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.4f];
        [self addSubview:self.topOverlayView];
        
        self.leftOverlayView = [[UIView alloc] init];
        self.leftOverlayView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.4f];
        [self addSubview:self.leftOverlayView];
        
        self.rightOverlayView = [[UIView alloc] init];
        self.rightOverlayView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.4f];
        [self addSubview:self.rightOverlayView];
        
        self.bottomOverlayView = [[UIView alloc] init];
        self.bottomOverlayView.backgroundColor = [UIColor colorWithWhite:1.f alpha:.4f];
        [self addSubview:self.bottomOverlayView];
    } else {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        self.tapGestureRecognizer.delegate = self;
        self.tapGestureRecognizer.numberOfTouchesRequired = 1;
        self.tapGestureRecognizer.numberOfTapsRequired = 1;
        [self addGestureRecognizer:self.tapGestureRecognizer];
        
        self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGestureRecognizer.delegate = self;
        self.panGestureRecognizer.enabled = NO;
        [self addGestureRecognizer:self.panGestureRecognizer];
    }
}

#pragma mark - View Layout

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.userInteractionEnabled) {
        return nil;
    }
    
    if (self.type == kXXCropViewTypeRect) {
        UIView *hitView = [self.cropRectView hitTest:[self convertPoint:point toView:self.cropRectView] withEvent:event];
        if (hitView) {
            return hitView;
        }
    }
    
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * self.scrollView.zoomScale, locationInImageView.y * self.scrollView.zoomScale);
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
        return self.scrollView;
    }
    
    [(UINavigationController *)self.viewController setNavigationBarHidden:![(UINavigationController *)self.viewController isNavigationBarHidden] animated:YES];
    
    return [super hitTest:point withEvent:event];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.image) {
        return;
    }
    
    UIInterfaceOrientation interfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    self.editingRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
    
    if (!self.imageView) {
        self.insetRect = CGRectInset(self.bounds, MarginLeft, MarginTop);
        
        [self setupImageView];
    }
    
    if (!self.isResizing) {
        if (self.type == kXXCropViewTypeRect) {
            [self layoutCropRectViewWithCropRect:self.scrollView.frame];
        }
        
        if (self.interfaceOrientation != interfaceOrientation) {
            [self zoomToCropRect:self.scrollView.frame];
        }
    }
    
    self.interfaceOrientation = interfaceOrientation;
}

- (void)setupImageView
{
    CGRect cropRect = AVMakeRectWithAspectRatioInsideRect(self.image.size, self.insetRect);
    
    self.scrollView.frame = cropRect;
    self.scrollView.contentSize = cropRect.size;
    
    self.zoomingView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.zoomingView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.zoomingView];
    
    self.maskFlagView = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.maskFlagView.backgroundColor = [UIColor clearColor];
    [self.scrollView addSubview:self.maskFlagView];
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.zoomingView.bounds];
    self.imageView.backgroundColor = [UIColor clearColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.image = self.image;
    self.imageView.layer.magnificationFilter = kCAFilterNearest;
    self.imageView.layer.minificationFilter = kCAFilterNearest;
    [self.zoomingView addSubview:self.imageView];
}

#pragma mark - Image Related

- (void)setAllowsRotate:(BOOL)allowsRotate {
    _allowsRotate = allowsRotate;
    self.rotationGestureRecognizer.enabled = allowsRotate;
}

- (void)setAllowsOperation:(BOOL)allowsOperation {
    _allowsOperation = allowsOperation;
    self.scrollView.scrollEnabled = allowsOperation;
    self.scrollView.pinchGestureRecognizer.enabled = allowsOperation;
    self.panGestureRecognizer.enabled = !allowsOperation;
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    lastPreviewCorner = 0;
    
    [self.imageView removeFromSuperview];
    self.imageView = nil;
    
    [self.zoomingView removeFromSuperview];
    self.zoomingView = nil;
    
    [self.maskFlagView removeFromSuperview];
    self.maskFlagView = nil;
    
    self.imagePreview.imageToMagnify = image;
    [self setNeedsLayout];
}

#pragma mark - Rotate

- (CGAffineTransform)rotation
{
    return self.imageView.transform;
}

- (CGFloat)rotationAngle
{
    CGAffineTransform rotation = self.imageView.transform;
    return atan2f(rotation.b, rotation.a);
}

- (void)setRotationAngle:(CGFloat)rotationAngle
{
    self.imageView.transform = CGAffineTransformMakeRotation(rotationAngle);
}

- (void)setRotationAngle:(CGFloat)rotationAngle snap:(BOOL)snap
{
    if (snap)
    {
        rotationAngle = (CGFloat) (nearbyintf((float) (rotationAngle / M_PI_2)) * M_PI_2);
    }
    self.rotationAngle = rotationAngle;
}

- (void)rotateLeft {
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, -M_PI_2);
}

- (void)rotateRight {
    self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, M_PI_2);
}

#pragma mark - Crop Layout

- (void)layoutCropRectViewWithCropRect:(CGRect)cropRect
{
    self.cropRectView.frame = cropRect;
    [self layoutOverlayViewsWithCropRect:cropRect];
}

- (void)layoutOverlayViewsWithCropRect:(CGRect)cropRect
{
    self.topOverlayView.frame = CGRectMake(0.0f,
                                           0.0f,
                                           CGRectGetWidth(self.bounds),
                                           CGRectGetMinY(cropRect));
    self.leftOverlayView.frame = CGRectMake(0.0f,
                                            CGRectGetMinY(cropRect),
                                            CGRectGetMinX(cropRect),
                                            CGRectGetHeight(cropRect));
    self.rightOverlayView.frame = CGRectMake(CGRectGetMaxX(cropRect),
                                             CGRectGetMinY(cropRect),
                                             CGRectGetWidth(self.bounds) - CGRectGetMaxX(cropRect),
                                             CGRectGetHeight(cropRect));
    self.bottomOverlayView.frame = CGRectMake(0.0f,
                                              CGRectGetMaxY(cropRect),
                                              CGRectGetWidth(self.bounds),
                                              CGRectGetHeight(self.bounds) - CGRectGetMaxY(cropRect));
}

#pragma mark - Crop Setter / Getter

- (void)setKeepingCropAspectRatio:(BOOL)keepingCropAspectRatio
{
    _keepingCropAspectRatio = keepingCropAspectRatio;
    self.cropRectView.keepingAspectRatio = self.keepingCropAspectRatio;
}

- (CGFloat)cropAspectRatio
{
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    return width / height;
}

- (void)setCropAspectRatio:(CGFloat)aspectRatio
{
    [self setCropAspectRatio:aspectRatio andCenter:YES];
}

- (void)setCropAspectRatio:(CGFloat)aspectRatio andCenter:(BOOL)center
{
    CGRect cropRect = self.scrollView.frame;
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    if (aspectRatio <= 1.0f) {
        width = height * aspectRatio;
        if (width > CGRectGetWidth(self.imageView.bounds)) {
            width = CGRectGetWidth(cropRect);
            height = width / aspectRatio;
        }
    } else {
        height = width / aspectRatio;
        if (height > CGRectGetHeight(self.imageView.bounds)) {
            height = CGRectGetHeight(cropRect);
            width = height * aspectRatio;
        }
    }
    cropRect.size = CGSizeMake(width, height);
    [self zoomToCropRect:cropRect andCenter:center];
}

- (CGRect)cropRect
{
    return self.scrollView.frame;
}

- (void)setCropRect:(CGRect)cropRect
{
    [self zoomToCropRect:cropRect];
}

- (void)setImageCropRect:(CGRect)imageCropRect
{
    [self resetCropRect];
    
    CGRect scrollViewFrame = self.scrollView.frame;
    CGSize imageSize = self.image.size;
    
    CGFloat scale = MIN(CGRectGetWidth(scrollViewFrame) / imageSize.width,
                        CGRectGetHeight(scrollViewFrame) / imageSize.height);
    
    CGFloat x = CGRectGetMinX(imageCropRect) * scale + CGRectGetMinX(scrollViewFrame);
    CGFloat y = CGRectGetMinY(imageCropRect) * scale + CGRectGetMinY(scrollViewFrame);
    CGFloat width = CGRectGetWidth(imageCropRect) * scale;
    CGFloat height = CGRectGetHeight(imageCropRect) * scale;
    
    CGRect rect = CGRectMake(x, y, width, height);
    CGRect intersection = CGRectIntersection(rect, scrollViewFrame);
    
    if (!CGRectIsNull(intersection)) {
        self.cropRect = intersection;
    }
}

#pragma mark - Crop Reset

- (void)resetCropRect
{
    [self resetCropRectAnimated:NO];
}

- (void)resetCropRectAnimated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationBeginsFromCurrentState:YES];
    }
    
    self.imageView.transform = CGAffineTransformIdentity;
    
    CGSize contentSize = self.scrollView.contentSize;
    CGRect initialRect = CGRectMake(0.0f, 0.0f, contentSize.width, contentSize.height);
    [self.scrollView zoomToRect:initialRect animated:NO];
    
    self.scrollView.bounds = self.imageView.bounds;
    
    if (self.type == kXXCropViewTypeRect) {
        [self layoutCropRectViewWithCropRect:self.scrollView.bounds];
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
    
    if (self.type == kXXCropViewTypeRect) {
        [self zoomedRectUpdated:CGRectMake(0, 0, self.image.size.width, self.image.size.height)];
    }
}

#pragma mark - Crop Image

- (UIImage *)croppedImage
{
    return [self.image rotatedImageWithtransform:self.rotation croppedToRect:self.zoomedCropRect];
}

- (CGRect)cappedCropRectInImageRectWithCropRectView:(XXCropRectView *)cropRectView
{
    CGRect cropRect = cropRectView.frame;
    
    CGRect rect = [self convertRect:cropRect toView:self.scrollView];
    if (CGRectGetMinX(rect) < CGRectGetMinX(self.zoomingView.frame)) {
        cropRect.origin.x = CGRectGetMinX([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        CGFloat cappedWidth = CGRectGetMaxX(rect);
        cropRect.size = CGSizeMake(cappedWidth,
                                   !self.keepingCropAspectRatio ? cropRect.size.height : cropRect.size.height * (cappedWidth/cropRect.size.width));
    }
    if (CGRectGetMinY(rect) < CGRectGetMinY(self.zoomingView.frame)) {
        cropRect.origin.y = CGRectGetMinY([self.scrollView convertRect:self.zoomingView.frame toView:self]);
        CGFloat cappedHeight =  CGRectGetMaxY(rect);
        cropRect.size = CGSizeMake(!self.keepingCropAspectRatio ? cropRect.size.width : cropRect.size.width * (cappedHeight / cropRect.size.height),
                                   cappedHeight);
    }
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(self.zoomingView.frame)) {
        CGFloat cappedWidth = CGRectGetMaxX([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinX(cropRect);
        cropRect.size = CGSizeMake(cappedWidth,
                                   !self.keepingCropAspectRatio ? cropRect.size.height : cropRect.size.height * (cappedWidth/cropRect.size.width));
    }
    if (CGRectGetMaxY(rect) > CGRectGetMaxY(self.zoomingView.frame)) {
        CGFloat cappedHeight =  CGRectGetMaxY([self.scrollView convertRect:self.zoomingView.frame toView:self]) - CGRectGetMinY(cropRect);
        cropRect.size = CGSizeMake(!self.keepingCropAspectRatio ? cropRect.size.width : cropRect.size.width * (cappedHeight / cropRect.size.height),
                                   cappedHeight);
    }
    
    return cropRect;
}

#pragma mark - Crop Zoom

- (CGRect)zoomedCropRect
{
    CGRect cropRect = [self convertRect:self.scrollView.frame toView:self.zoomingView];
    return [self zoomedRect:cropRect];
}

- (CGRect)zoomedRect:(CGRect)cropRect {
    CGSize size = self.image.size;
    
    CGFloat ratio = 1.0f;
    UIInterfaceOrientation orientation = self.interfaceOrientation;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        ratio = CGRectGetWidth(AVMakeRectWithAspectRatioInsideRect(size, self.insetRect)) / size.width;
    } else {
        ratio = CGRectGetHeight(AVMakeRectWithAspectRatioInsideRect(size, self.insetRect)) / size.height;
    }
    
    CGRect zoomedCropRect = CGRectMake(cropRect.origin.x / ratio,
                                       cropRect.origin.y / ratio,
                                       cropRect.size.width / ratio,
                                       cropRect.size.height / ratio);
    
    return zoomedCropRect;
}

- (void)automaticZoomIfEdgeTouched:(CGRect)cropRect
{
    if (CGRectGetMinX(cropRect) < CGRectGetMinX(self.editingRect) - 5.0f ||
        CGRectGetMaxX(cropRect) > CGRectGetMaxX(self.editingRect) + 5.0f ||
        CGRectGetMinY(cropRect) < CGRectGetMinY(self.editingRect) - 5.0f ||
        CGRectGetMaxY(cropRect) > CGRectGetMaxY(self.editingRect) + 5.0f) {
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self zoomToCropRect:self.cropRectView.frame];
        } completion:NULL];
    }
}

- (BOOL)userHasModifiedCropArea
{
    CGRect zoomedCropRect = CGRectIntegral(self.zoomedCropRect);
    return (!CGPointEqualToPoint(zoomedCropRect.origin, CGPointZero) ||
            !CGSizeEqualToSize(zoomedCropRect.size, self.image.size) ||
            !CGAffineTransformEqualToTransform(self.rotation, CGAffineTransformIdentity));
}


#pragma mark - Crop Gesture

- (void)touchesBegan:(NSSet<UITouch *> *)touches
           withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        UITouch *t = [touches anyObject];
        CGPoint p = [t locationInView:self];
        _lastPoint = p;
    }
}

- (void)cropRectViewDidBeginEditing:(XXCropRectView *)cropRectView
{
    self.resizing = YES;
    self.imagePreview.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    [self movePreviewByPoint:_lastPoint];
    [self.imagePreview makeKeyAndVisible];
}

- (void)cropRectViewEditingChanged:(XXCropRectView *)cropRectView
{
    CGRect cropRect = [self cappedCropRectInImageRectWithCropRectView:cropRectView];
    [self layoutCropRectViewWithCropRect:cropRect];

    CGPoint currentPoint = CGPointZero;
    CGRect zoomedRect = [self zoomedRect:[self convertRect:cropRect toView:self.zoomingView]];
    if (cropRectView.resizeControlPosition == kXXResizeControlPositionTopLeft) {
        currentPoint = CGPointMake(zoomedRect.origin.x, zoomedRect.origin.y);
    } else if (cropRectView.resizeControlPosition == kXXResizeControlPositionTopRight) {
        currentPoint = CGPointMake(zoomedRect.origin.x + zoomedRect.size.width, zoomedRect.origin.y);
    } else if (cropRectView.resizeControlPosition == kXXResizeControlPositionBottomLeft) {
        currentPoint = CGPointMake(zoomedRect.origin.x, zoomedRect.origin.y + zoomedRect.size.height);
    } else if (cropRectView.resizeControlPosition == kXXResizeControlPositionBottomRight) {
        currentPoint = CGPointMake(zoomedRect.origin.x + zoomedRect.size.width, zoomedRect.origin.y + zoomedRect.size.height);
    }
    
    [self.imagePreview setPointToMagnify:currentPoint];
    [self zoomedRectUpdated:zoomedRect];
}

- (void)cropRectViewDidEndEditing:(XXCropRectView *)cropRectView
{
    if (self.scrollView.pinchGestureRecognizer.enabled) {
        [self zoomToCropRect:self.cropRectView.frame];
    }
    [self.imagePreview setHidden:YES];
    self.resizing = NO;
}

- (void)zoomToCropRect:(CGRect)toRect
{
    [self zoomToCropRect:toRect andCenter:NO];
}

- (void)zoomToCropRect:(CGRect)toRect andCenter:(BOOL)center
{
    if (CGRectEqualToRect(self.scrollView.frame, toRect)) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(toRect);
    CGFloat height = CGRectGetHeight(toRect);
    
    CGFloat scale = MIN(CGRectGetWidth(self.editingRect) / width, CGRectGetHeight(self.editingRect) / height);
    
    CGFloat scaledWidth = width * scale;
    CGFloat scaledHeight = height * scale;
    CGRect cropRect = CGRectMake((CGRectGetWidth(self.bounds) - scaledWidth) / 2,
                                 (CGRectGetHeight(self.bounds) - scaledHeight) / 2,
                                 scaledWidth,
                                 scaledHeight);
    
    CGRect zoomRect = [self convertRect:toRect toView:self.zoomingView];
    zoomRect.size.width = CGRectGetWidth(cropRect) / (self.scrollView.zoomScale * scale);
    zoomRect.size.height = CGRectGetHeight(cropRect) / (self.scrollView.zoomScale * scale);
    
    if (center) {
        CGRect imageViewBounds = self.imageView.bounds;
        zoomRect.origin.y = (CGRectGetHeight(imageViewBounds) / 2) - (CGRectGetHeight(zoomRect) / 2);
        zoomRect.origin.x = (CGRectGetWidth(imageViewBounds) / 2) - (CGRectGetWidth(zoomRect) / 2);
    }
    
    [UIView animateWithDuration:0.4f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.scrollView.bounds = cropRect;
        if (self.type == kXXCropViewTypeRect) {
            [self layoutCropRectViewWithCropRect:cropRect];
        }
        [self.scrollView zoomToRect:zoomRect animated:NO];
    } completion:NULL];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.zoomingView;
}

#pragma mark - Rotate Gesture

- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer
{
    CGFloat rotation = gestureRecognizer.rotation;
    
    CGAffineTransform transform = CGAffineTransformRotate(self.imageView.transform, rotation);
    self.imageView.transform = transform;
    gestureRecognizer.rotation = 0.0f;
    
    if (self.type == kXXCropViewTypeRect) {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            self.cropRectView.showsGridMinor = YES;
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded ||
                   gestureRecognizer.state == UIGestureRecognizerStateCancelled ||
                   gestureRecognizer.state == UIGestureRecognizerStateFailed) {
            self.cropRectView.showsGridMinor = NO;
        }
    }
}

#pragma mark - Tap Gesture

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [gestureRecognizer locationInView:self];
        CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
        CGFloat zoomScale = self.scrollView.zoomScale;
        CGPoint zoomedPoint = CGPointMake(locationInImageView.x * zoomScale, locationInImageView.y * zoomScale);
        if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
            CGRect zoomedRect = [self zoomedRect:CGRectMake(locationInImageView.x, locationInImageView.y, 0, 0)];
            CGPoint p = zoomedRect.origin;
            if (self.type == kXXCropViewTypeColor ||
                self.type == kXXCropViewTypePosition ||
                self.type == kXXCropViewTypePositionColor) {
                [self removeAllFlagViews];
                [self addFlagViewAtPoint:locationInImageView];
            }
            UIColor *c = [self.imagePreview getColorOfPoint:p];
            if (self.type == kXXCropViewTypeColor) {
                [self colorUpdated:c];
            } else if (self.type == kXXCropViewTypePosition) {
                [self zoomedPointUpdated:p];
            } else if (self.type == kXXCropViewTypePositionColor) {
                [self modelUpdatedWithPosition:p andColor:c];
            }
        }
    }
}

#pragma mark - Pan Gesture

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    CGPoint locationInImageView = [self convertPoint:point toView:self.zoomingView];
    CGFloat zoomScale = self.scrollView.zoomScale;
    CGPoint zoomedPoint = CGPointMake(locationInImageView.x * zoomScale, locationInImageView.y * zoomScale);
    if (CGRectContainsPoint(self.zoomingView.frame, zoomedPoint)) {
        CGRect zoomedRect = [self zoomedRect:CGRectMake(locationInImageView.x, locationInImageView.y, 0, 0)];
        CGPoint p = zoomedRect.origin;
        [self.imagePreview setPointToMagnify:p];
        if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
            [self movePreviewByPoint:point];
        } else if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
            self.imagePreview.statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
            [self movePreviewByPoint:point];
            [self.imagePreview makeKeyAndVisible];
        } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
            // Ended and mark
            if (self.type == kXXCropViewTypeColor ||
                self.type == kXXCropViewTypePosition ||
                self.type == kXXCropViewTypePositionColor) {
                [self removeAllFlagViews];
                [self addFlagViewAtPoint:locationInImageView];
            }
        }
        UIColor *c = self.imagePreview.colorOfLastPoint;
        if (self.type == kXXCropViewTypeColor) {
            [self colorUpdated:c];
        } else if (self.type == kXXCropViewTypePosition) {
            [self zoomedPointUpdated:p];
        } else if (self.type == kXXCropViewTypePositionColor) {
            [self modelUpdatedWithPosition:p andColor:c];
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded || gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        [self.imagePreview setHidden:YES];
    }
}

#pragma mark - Flag

- (NSMutableArray <XXImageFlagView *> *)flagViews {
    if (!_flagViews) {
        _flagViews = [[NSMutableArray alloc] init];
    }
    return _flagViews;
}

- (void)addFlagViewAtPoint:(CGPoint)p {
    CGFloat zoomScale = self.scrollView.zoomScale;
    XXImageFlagView *newFlagView = [[XXImageFlagView alloc] initWithFrame:CGRectMake(0, 0, 22.f, 22.f)];
    newFlagView.center = CGPointMake(p.x * zoomScale, p.y * zoomScale);
    newFlagView.originalModel = [XXPositionColorModel modelWithPosition:p andColor:nil];
    [self.maskFlagView addSubview:newFlagView];
    [self.flagViews addObject:newFlagView];
}

- (void)removeAllFlagViews {
    for (XXImageFlagView *v in self.flagViews) {
        [v removeFromSuperview];
    }
    [self.flagViews removeAllObjects];
}

- (void)adjustFlagViews {
    for (XXImageFlagView *v in self.flagViews) {
        CGFloat zoomScale = self.scrollView.zoomScale;
        CGPoint p = v.originalModel.position;
        v.center = CGPointMake(p.x * zoomScale, p.y * zoomScale);
    }
}

#pragma mark - Gestures

- (void)zoomedPointUpdated:(CGPoint)zoomedPoint {
    XXPositionPickerController *pickerController = (XXPositionPickerController *)self.viewController;
    pickerController.currentPoint = zoomedPoint;
}

- (void)zoomedRectUpdated:(CGRect)zoomedRect {
    XXRectPickerController *pickerController = (XXRectPickerController *)self.viewController;
    pickerController.currentRect = zoomedRect;
}

- (void)colorUpdated:(UIColor *)color {
    XXColorPickerController *pickerController = (XXColorPickerController *)self.viewController;
    pickerController.currentColor = color;
}

- (void)modelUpdatedWithPosition:(CGPoint)p andColor:(UIColor *)c {
    XXPositionColorModel *model = [XXPositionColorModel new];
    model.position = p; model.color = c;
    XXPosColorPickerController *pickerController = (XXPosColorPickerController *)self.viewController;
    pickerController.currentModel = model;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Area Event

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.type == kXXCropViewTypeRect) {
        [self zoomedRectUpdated:self.zoomedCropRect];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.type == kXXCropViewTypeRect) {
        [self zoomedRectUpdated:self.zoomedCropRect];
    } else {
        [self adjustFlagViews];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGPoint contentOffset = scrollView.contentOffset;
    *targetContentOffset = contentOffset;
}

#pragma mark - Preview

- (XXImagePickerPixelPreview *)imagePreview {
    if (!_imagePreview) {
        _imagePreview = [[XXImagePickerPixelPreview alloc] init];
        [_imagePreview setHidden:YES];
    }
    return _imagePreview;
}

- (void)movePreviewByPoint:(CGPoint)p {
    CGFloat sW = [UIScreen mainScreen].bounds.size.width;
    CGFloat sH = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = (int)(MIN(sW, sH) / 20.f) * 10.f;
    if (p.x < sW / 2.f) {
        if (p.y < sH / 2.f) {
            // 2
            if (lastPreviewCorner != 2) {
                lastPreviewCorner = 2;
                self.imagePreview.frame = CGRectMake(sW - width, sH - width, width, width);
            }
        } else {
            // 4
            if (lastPreviewCorner != 4) {
                lastPreviewCorner = 4;
                self.imagePreview.frame = CGRectMake(sW - width, 0, width, width);
            }
        }
    } else {
        if (p.y < sH / 2.f) {
            // 1
            if (lastPreviewCorner != 1) {
                lastPreviewCorner = 1;
                self.imagePreview.frame = CGRectMake(0, sH - width, width, width);
            }
        } else {
            // 3
            if (lastPreviewCorner != 3) {
                lastPreviewCorner = 3;
                self.imagePreview.frame = CGRectMake(0, 0, width, width);
            }
        }
    }
}

@end
