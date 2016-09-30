//
//  CMPMapMarkerView.h

//
//  Created by Moshe on 7/28/14.
//  Copyright (c) 2014 Moshe Berman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MBMarkerView : UIView

/**
 *  The border color of the marker.
 */

@property (nonatomic, strong) UIColor *color;

/***
 *  The border width of the marker.
 */

@property (nonatomic, assign) CGFloat borderWidth;

/**
 *  The diameter of the marker. Values less than zero are ignored. Summarily.
 */

@property (nonatomic, assign) CGFloat radius;

/**
 *  Toggles animation.
 */

@property (nonatomic, assign) BOOL animated;

/**
 *  Setting the diameter simply calls setRadius: now.
 *
 *  @param diameter Twice the radius to set.
 */

- (void)setDiameter:(CGFloat)diameter;

@end
