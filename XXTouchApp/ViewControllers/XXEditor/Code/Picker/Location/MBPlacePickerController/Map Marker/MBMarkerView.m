//
//  CMPMapMarkerView.m
//  
//
//  Created by Moshe on 7/28/14.
//  Copyright (c) 2014 Moshe Berman. All rights reserved.
//

#import "MBMarkerView.h"

@interface MBMarkerView ()

/**
 *  An outline view that pulses.
 */

@property (nonatomic, strong) UIView *pulsingView;

@end

@implementation MBMarkerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _color = [UIColor blueColor];
        _borderWidth = 2.0f;
        _radius = 20.0f;
        _pulsingView = [[UIView alloc] init];
        _animated = YES;
        self.clipsToBounds = NO;
        self.userInteractionEnabled = NO;
    }
    return self;
}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.pulsingView.layer.cornerRadius = self.layer.cornerRadius;
    self.pulsingView.frame = self.bounds;
    
    [self addSubview:self.pulsingView];
    [self applyAnimationSettings];
}

- (void)didMoveToSuperview
{
    [self setNeedsDisplay];
}

#pragma mark - Custom Setters

/**
 *  Set the color.
 *
 *
 */

- (void)setColor:(UIColor *)color
{
    if(color == nil)
    {
        color = [[UIView appearance] tintColor];
    }
    
    _color = color;
    [self applyColor];
}

/**
 *  Set the border width.
 */

- (void)setBorderWidth:(CGFloat)borderWidth
{
    _borderWidth = borderWidth;
    
    [self applyBorderWidth];
}

/**
 *  Set the diameter.
 */

- (void)setRadius:(CGFloat)radius
{
    if(radius > 0)
    {
        _radius = radius;
        
        CGRect frame = self.frame;
        frame.size = CGSizeMake(radius*2, radius*2);
        self.frame = frame;
        
        self.layer.cornerRadius = radius;
        
        [self setNeedsDisplay];
    }
}

/**
 *  Set the animated state.
 */

- (void)setAnimated:(BOOL)animated
{
    _animated = animated;
    
    [self applyAnimationSettings];
}


#pragma mark - Property Applicators

/** ---
 *  @name Property Applicators
 *  ---
 */

/**
 *  Applies the colors to the pulsing view.
 */

- (void)applyColor
{
    UIColor *color = self.color;
    
    self.layer.borderColor = color.CGColor;
    self.backgroundColor = [color colorWithAlphaComponent:0.5f];
    
    self.pulsingView.layer.borderColor = [color colorWithAlphaComponent:0.7].CGColor;
}

/**
 *  Applies border width.
 */

- (void)applyBorderWidth
{
    
    CGFloat borderWidth = self.borderWidth;
    
    self.layer.borderWidth = borderWidth;
    
    self.pulsingView.layer.borderWidth = borderWidth;
}

/**
 *
 */

- (void)applyAnimationSettings
{
    [self stopAnimating];
    
    if (self.animated)
    {
        [self pulse];
    }
}

#pragma mark - Pulse animation

/**
 *
 */

- (void)stopAnimating
{
    [self.pulsingView.layer removeAllAnimations];
    [self.layer removeAllAnimations];
}

/***
 *
 */

- (void)pulse
{
    [self addSubview:self.pulsingView];
    
    self.pulsingView.alpha = 0.0f;
    self.pulsingView.transform = CGAffineTransformIdentity;

    
    [UIView animateWithDuration:0.9
                          delay: 0.0
                         options: (UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                     animations:^{
                         self.pulsingView.alpha = 1.0;
                         self.pulsingView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.8, 0.8);
                     }
                     completion:^(BOOL finished) {
                         self.pulsingView.transform = CGAffineTransformIdentity;
                     }];
}

#pragma mark - Diameter

/**
 *  Setting the diameter simply calls setRadius: now.
 *
 *  @param diameter Twice the radius to set.
 */

- (void)setDiameter:(CGFloat)diameter
{
    [self setRadius:diameter/2.0f];
}

@end
