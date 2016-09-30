//
//  MBMapView.m
//  MBPlacePickerController
//
//  Created by Moshe on 6/30/14.
//  Copyright (c) 2014 Corlear Apps. All rights reserved.
//

#import "MBMapView.h"
#import "MBLocationManager.h"
#import "MBMarkerView.h"

@interface MBMapView ()

/**
 *  References the last known coordinate.
 */

@property (nonatomic, assign) CLLocationCoordinate2D lastCoordinate;

/**
 *  The marker for the user's location.
 */

@property (nonatomic, strong) MBMarkerView *_userMarkerView;

/**
 *
 */

@property (nonatomic, strong) MBMarkerView *_markedLocationView;

@end

/**
 *  This view is capable of displaying markers on a map.
 */

@implementation MBMapView

#pragma mark - Initializers

/** ---
 *  @name Initializers
 *  ---
 */

/**
 *  @return An initialized map picker view.
 */

- (instancetype)init
{
    self = [super initWithImage:[UIImage imageNamed:@"equi-map"]];
    if (self)
    {
        _markerDiameter = 15.0f;
        _markerColor = [UIColor redColor];
        _showUserLocation = NO;
    }
    return self;
}

- (void)didMoveToSuperview
{
    if (self.showUserLocation)
    {
        [self _updateUserLocation];
    }
}

- (void)removeFromSuperview
{
    [[self marker] removeFromSuperview];
    
    [super removeFromSuperview];
}

#pragma mark - Converting between UIKit Coordinates and Geographical Coordinates

/** ---
 *  @name Converting between UIKit Coordinates and Geographical Coordinates
 *  ---
 */

/**
 *  Converts a latitude and longitude to a CGPoint in the map view's coordinate space.
 *
 *  @param latitude The latitude to use.
 *  @param longiutde The longitude to use.
 *
 *  @return A CGPoint in the view's coordinate space.
 */

- (CGPoint)pointFromLatitude:(CGFloat)latitude andLongitude:(CGFloat)longitude
{
    CGRect bounds = self.bounds;
    
    CGFloat longitudeFraction = longitude/180.0f;
    CGFloat longitudeAsPoint = longitudeFraction * CGRectGetMidX(bounds);
    
    CGFloat latitudeFraction = -(latitude/90.0f);
    CGFloat latitudeAsPoint = latitudeFraction * CGRectGetMidY(bounds);
    
    CGFloat midX = CGRectGetMidX(bounds);
    CGFloat midY = CGRectGetMidY(bounds);
    
    CGPoint center = CGPointMake(longitudeAsPoint + midX, latitudeAsPoint + midY);
    
    return center;
}

/**
 *  Converts a local coordinate plane point to a lat/lon point.
 *
 *  @param point A CGPoint in the map's coordinate space.
 */

- (CLLocationCoordinate2D)coordinateFromPoint:(CGPoint)point
{
    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    CGFloat xDistanceFromCenter = center.x - point.x;
    CGFloat yDistanceFromCenter = center.y - point.y;
    
    CGFloat xRatio = xDistanceFromCenter/CGRectGetMidX(bounds);
    CGFloat yRatio = yDistanceFromCenter/CGRectGetMidY(bounds);
    
    CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(90*yRatio, 180*xRatio);
    
    return coord;
}

#pragma mark - Getting Marker Views

/** ---
 *  @name Getting Marker Views
 *  ---
 */
/**
 *  A marker for a location.
 */

- (MBMarkerView *)marker
{
    if (!self._markedLocationView)
    {
        self._markedLocationView = [[MBMarkerView alloc] init];
        self._markedLocationView.radius = self.markerDiameter;
        self._markedLocationView.borderWidth = 1.0f;
    }
    
    self._markedLocationView.color = self.markerColor;
    
    return self._markedLocationView;
}

/**
 *  @return A marker representing the user's location.
 */

- (MBMarkerView *)userMarker
{
    if (!self._userMarkerView)
    {
        self._userMarkerView = [[MBMarkerView alloc] init];
        self._userMarkerView.radius = 8.0f;
        self._userMarkerView.borderWidth = 1.0f;
    }
    
    self._userMarkerView.color = self.tintColor;
    
    return self._userMarkerView;
}

#pragma mark -  Displaying Markers

/** ---
 *  @name Displaying Markers
 *  ---
 */

/**
 *  Displays a marker on the given coordinate.
 */

- (void)markCoordinate:(CLLocationCoordinate2D)coordinate
{
    CGPoint center = [self pointFromLatitude:coordinate.latitude andLongitude:coordinate.longitude];
    
    MBMarkerView *marker = [self marker];
    
    [marker setRadius:self.markerDiameter];
    
    if (![self.subviews containsObject:[self marker]])
    {
        marker.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
        
        [marker setCenter:center];
        [self addSubview:marker];
        marker.transform = CGAffineTransformIdentity;
        
    }
    else
    {
        [UIView animateWithDuration:0.20
                         animations:^{
                             [marker setCenter:center];
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
    
    
    
    
    
    
    self.lastCoordinate = coordinate;
}

/**
 *  Refresh the marker with new settings.
 */

- (void)refreshMarker
{
    [self markCoordinate:self.lastCoordinate];
}

#pragma mark - Hiding the Marker

/**
 *  Shrinks the marker and then removes it from the map.
 */

- (void)hideMarker
{
    if ([self.subviews containsObject:[self marker]])
    {
        UIView *marker = [self marker];
        if ([self.subviews containsObject:marker])
        {
            [UIView animateWithDuration:0.3 animations:^{
                
                marker.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0, 0);
                
            } completion:^(BOOL finished) {
                [marker removeFromSuperview];
                marker.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

#pragma mark - Custom Setters

/** ---
 *  @name Custom Setters
 *  ---
 */

/**
 *  Set the location marker's color.
 *
 *  @discussion Setting to nil will default to red.
 *
 *  @param indicatorColor The color to change the indicator to.
 */

- (void)setMarkerColor:(UIColor *)markerColor
{
    if (!markerColor)
    {
        markerColor = [UIColor redColor];
    }
    _markerColor = markerColor;
    
    [self refreshMarker];
}

/**
 *  Set the indicator radius. Setting to a negative will do nothing.
 */

- (void)setMarkerDiameter:(CGFloat)markerDiameter
{
    if (markerDiameter < 0)
    {
        return;
    }
    _markerDiameter = markerDiameter;
    
    [self refreshMarker];
}

/**
 *  @param showUserLocation A parameter controlling wether to show the user's location.
 */

- (void)setShowUserLocation:(BOOL)showUserLocation
{
    _showUserLocation = showUserLocation;
    
    if (_showUserLocation)
    {
        [self _updateUserLocation];
    }
    else
    {
        [[self userMarker] removeFromSuperview];
        [[MBLocationManager sharedManager] stopUpdatingLocation];
    }
}

#pragma mark - Update User Location

/**
 *  Updates the user's location and shows the marker when the location manager returns fresh data.
 */

- (void)_updateUserLocation
{
    
    [[MBLocationManager sharedManager] updateLocationWithCompletionHandler:^(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus) {
        
        CLLocation *location = [[MBLocationManager sharedManager] location];
        
        if (location) {
            CGPoint userMarkerCenter = [self pointFromLatitude:location.coordinate.latitude andLongitude:location.coordinate.longitude];
            [[self userMarker] setCenter:userMarkerCenter];
            [self addSubview:[self userMarker]];
            
            /**
             *  Keep the selected marker above the location marker.
             */
            
            if ([self.subviews containsObject:[self marker]])
            {
                [self bringSubviewToFront:[self marker]];
            }
        }
        
        
    }];
    
}
@end
