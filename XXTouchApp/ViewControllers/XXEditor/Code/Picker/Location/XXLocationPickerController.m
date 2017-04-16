//
//  XXLocationPickerController.m
//  XXTouchApp
//
//  Created by Zheng on 10/8/16.
//  Copyright © 2016 Zheng. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "XXLocationPickerController.h"
#import "XXCodeMakerService.h"
#import "XXLocalDataService.h"

static NSString * const kXXCoordinateRegionLatitudeKey = @"kXXCoordinateRegionLatitudeKey";
static NSString * const kXXCoordinateRegionLongitudeKey = @"kXXCoordinateRegionLongitudeKey";
static NSString * const kXXMapViewAnnotationIdentifier = @"kXXMapViewAnnotationIdentifier";
static NSString * const kXXMapViewAnnotationFormat = @"Latitude: %f, Longitude: %f";

@interface XXLocationPickerController () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) MKPointAnnotation *pointAnnotation;

@end

@implementation XXLocationPickerController

+ (NSString *)keyword {
    return @"@loc@";
}

+ (NSString *)storyboardName {
    return @"XXLocationPickerController";
}

+ (NSString *)storyboardID {
    return kXXLocationPickerControllerStoryboardID;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Location", nil);
    
    self.mapView.delegate = self;
    
    CLLocationCoordinate2D defaultCoordinate;
    defaultCoordinate.latitude = 39.92f;
    defaultCoordinate.longitude = 116.46f;
    MKCoordinateSpan defaultSpan = {1.f, 1.f};
    MKCoordinateRegion region = {defaultCoordinate, defaultSpan};
    id latitudeObj = [[XXLocalDataService sharedInstance] objectForKey:kXXCoordinateRegionLatitudeKey];
    id longitudeObj = [[XXLocalDataService sharedInstance] objectForKey:kXXCoordinateRegionLongitudeKey];
    if (
        latitudeObj && longitudeObj
        ) {
        defaultCoordinate.latitude = [(NSNumber *)latitudeObj floatValue];
        defaultCoordinate.longitude = [(NSNumber *)longitudeObj floatValue];
    }
    [self.mapView setRegion:region animated:YES];
    
    MKPointAnnotation *pointAnnotation = [[MKPointAnnotation alloc] init];
    if (self.codeBlock.currentStep == self.codeBlock.totalStep) {
        pointAnnotation.title = NSLocalizedString(@"Done", nil);
    } else {
        pointAnnotation.title = NSLocalizedString(@"Next", nil);
    }
    pointAnnotation.subtitle = [NSString stringWithFormat:NSLocalizedString(kXXMapViewAnnotationFormat, nil), defaultCoordinate.latitude, defaultCoordinate.longitude];
    pointAnnotation.coordinate = defaultCoordinate;
    [self.mapView addAnnotation:pointAnnotation];
    [self.mapView selectAnnotation:pointAnnotation animated:YES];
    self.pointAnnotation = pointAnnotation;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *customPinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:kXXMapViewAnnotationIdentifier];
    if (!customPinView) {
        customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kXXMapViewAnnotationIdentifier];

        if (SYSTEM_VERSION_LESS_THAN(@"9.0")) {
            customPinView.pinColor = MKPinAnnotationColorRed;
        } else {
            customPinView.pinTintColor = STYLE_TINT_COLOR;
        }

        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        customPinView.draggable = YES;
        UIButton *detailBtn = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [detailBtn setTarget:self action:@selector(selectCoordinate:) forControlEvents:UIControlEventTouchUpInside];
        customPinView.rightCalloutAccessoryView = detailBtn;
    } else {
        customPinView.annotation = annotation;
    }
    return customPinView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    MKPointAnnotation *anno = ((MKPointAnnotation *)view.annotation);
    NSString *dragTips = [NSString stringWithFormat:NSLocalizedString(kXXMapViewAnnotationFormat, nil), anno.coordinate.latitude, anno.coordinate.longitude];
    switch (newState) {
        case MKAnnotationViewDragStateStarting:
            break;
        case MKAnnotationViewDragStateDragging:
            break;
        case MKAnnotationViewDragStateEnding:
            anno.subtitle = dragTips;
            [[XXLocalDataService sharedInstance] setObject:@((float) anno.coordinate.latitude) forKey:kXXCoordinateRegionLatitudeKey];
            [[XXLocalDataService sharedInstance] setObject:@((float) anno.coordinate.longitude) forKey:kXXCoordinateRegionLongitudeKey];
            break;
        default:
            break;
    }
    self.subtitle = dragTips;
}

#pragma mark - Setter

- (void)selectCoordinate:(UIButton *)sender {
    [self pushToNextControllerWithKeyword:[[self class] keyword] replacement:self.previewString];
}

#pragma mark - Previewing Bar

- (NSString *)previewString {
    return [NSString stringWithFormat:@"%f, %f", self.pointAnnotation.coordinate.latitude, self.pointAnnotation.coordinate.longitude];
}

- (NSString *)subtitle {
    return NSLocalizedString(@"Select a location by dragging 📌", nil);
}

- (void)setSubtitle:(NSString *)subtitle {
    self.navigationController.title = subtitle;
}

#pragma mark - Memory

- (void)dealloc {
    XXLog(@"");
}

@end
