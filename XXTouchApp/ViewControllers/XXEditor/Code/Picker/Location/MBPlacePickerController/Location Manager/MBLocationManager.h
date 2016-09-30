//
//  MBLocationManager.h
//  MBLocationManager
//
//  Created by Moshe on 5/21/14.
//
//

#import <Foundation/Foundation.h>

@import CoreLocation;

typedef void(^MBLocationManagerUpdateCompletionBlock)(NSArray *locations, CLHeading *heading, CLAuthorizationStatus authorizationStatus);

@interface MBLocationManager : NSObject

/**
 *  Set the desired accuracy.
 */

@property () CLLocationAccuracy desiredAccuracy;

/**
 *  Singleton access.
 */

+ (MBLocationManager *)sharedManager;

/**
 *  Update the user's location with a completion block.
 *
 *  Will prompt the user for permission the first time.
 */

- (void)updateLocationWithCompletionHandler:(MBLocationManagerUpdateCompletionBlock)completion;

/**
 *  Stop updating the locations.
 */

- (void)stopUpdatingLocation;

/**
 *  The last known location of the location manager.
 */

- (CLLocation *)location;

/**
 *  The last known heading of the location manager.
 */

- (CLHeading *)heading;

#pragma mark - Authorization States

/**
 *  @return YES if the authorization status is not determined, else NO.
 */

- (BOOL)authorizationNotDetermined;

/**
 *  @return YES if authorized, else NO.
 */

- (BOOL)authorizedWhenInUse;

/**
 *  @eturn YES if authorized, else NO.
 */

- (BOOL)authorizedAlways;

/**
 *  @eturn YES if denied, else NO.
 */

- (BOOL)authorizationDenied;

/**
 *   @eturn YES if restricted, else NO.
 */

- (BOOL)authorizationRestricted;

@end
