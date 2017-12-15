//
//  MapViewController.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "MapViewController.h"
#import "User.h"
#import <GoogleMaps/GoogleMaps.h>
#import "DatabaseManager.h"
#import "AnnotationView.h"
#import "Constants.h"
#import "RouteManager.h"
#import "UIViewController+Error.h"

@interface MapViewController () <GMSMapViewDelegate>

@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) NSMutableArray *markers;
@property (strong, nonatomic) NSTimer *updateTimer;

@end

@implementation MapViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Route";
    
    _mapView.myLocationEnabled = YES;
    _mapView.delegate = self;
    _mapView.settings.myLocationButton = YES;
    
    [self updateDataSource];
    if (!_updateTimer) {
        self.updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateLocationInSeconds target:self selector:@selector(updateDataSource) userInfo:nil repeats:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (_updateTimer) {
        [_updateTimer invalidate];
        _updateTimer = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters

- (void)setUser:(User *)user {
    _user = user;
}

#pragma mark - Helpers

- (void)updateDataSource {
    self.markers = [[NSMutableArray alloc] init];
    [[DatabaseManager sharedManager] getLocationsForUserID:[_user.userID integerValue] completion:^(BOOL success, NSArray *result, NSError *error) {
        if (success) {
            for (Location *location in result) {
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake((CLLocationDegrees)[location.latitude doubleValue], (CLLocationDegrees)[location.longitude doubleValue]);
                marker.map = _mapView;
                marker.userData = @{@"vehicleLocation" : location};
                [_markers addObject:marker];
            }
            GMSMarker *marker = [_markers firstObject];
            if (marker) {
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:marker.position.latitude longitude:marker.position.longitude zoom:10];
                [_mapView animateToCameraPosition:camera];
            }
        } else {
            if ([error.localizedDescription containsString:@"html"] || error.code == -105) {
                [self showRetryErrorMessage:error.localizedDescription retry:^{
                    [self updateDataSource];
                } cancel:^{
                    //nothing to do
                }];
            } else {
                [self showErrorMessage:error.localizedDescription];
            }
        }
    }];
}

#pragma mark - GMSMapViewDelegate

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker {
    if (mapView.selectedMarker == marker) {
        [mapView setSelectedMarker:nil];
    } else {
        [mapView setSelectedMarker:marker];
        if ([marker.userData isKindOfClass:[NSDictionary class]]) {
            Location *location = marker.userData[@"vehicleLocation"];
            CLLocation *destinationLocation = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[location.latitude doubleValue] longitude:(CLLocationDegrees)[location.longitude doubleValue]];
            [[RouteManager sharedManager] buildRouteFrom:_mapView.myLocation to:destinationLocation inView:_mapView completion:^(BOOL success, NSError *error) {
                if (success) {
                    //route done
                } else {
                    [self showErrorMessage:error.localizedDescription];
                }
            }];
        }
    }
    
    return YES;
}

- (nullable UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker {
    AnnotationView *markerView = [[AnnotationView alloc] init];
    if ([marker.userData isKindOfClass:[NSDictionary class]]) {
        Location *location = [(NSDictionary *)marker.userData valueForKey:@"vehicleLocation"];
        markerView.vehicle = location.vehicle;
    }
    return markerView;
}

@end
