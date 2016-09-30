//
//  MBMapView.h
//  MBPlacePickerController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@import MapKit;

@interface MBMapView : UIImageView

/**
 *  The color of the location marker. 
 *
 *  @discussion The default is red. Setting to nil will default to red.
 */

@property (nonatomic, strong) UIColor *markerColor;

/**
 *  The radius of the indicator. The default is 30.0f;
 *   Setting to a negative will do nothing.
 */

@property (nonatomic, assign) CGFloat markerDiameter;

/**
 *  A flag to determine if the user's location should be displayed.
 *  Default is NO.
 */

@property (nonatomic, assign) BOOL showUserLocation;

/** ---
 *  @name Displaying/Hiding the marker.
 *  ---
 */

/**
 *  Displays a marker on the given coordinate.
 */

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 *  Shrinks the marker and then removes it from the map.
 */

- (void)hideMarker;

@end
