//
//  RouteManager.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "RouteManager.h"
#import "NetworkManager.h"
#import "Constants.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Location.h"

@import CoreLocation;

@interface RouteManager ()

@property (strong, nonatomic) GMSPolyline *polyline;

@end

@implementation RouteManager

+ (RouteManager *)sharedManager {
    static RouteManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)buildRouteFrom:(CLLocation *)source to:(CLLocation *)destination inView:(GMSMapView *)mapView completion:(void(^)(BOOL success, NSError *error))block {
    self.polyline = nil;
    
    if (!source) {
        NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-104 userInfo:@{NSLocalizedDescriptionKey : @"Unable to determine your location"}];
        block(NO, error);
        return;
    }
    
    NSDictionary *parameters = @{
                                 @"origin"          : [NSString stringWithFormat:@"%f,%f", source.coordinate.latitude, source.coordinate.longitude],
                                 @"destination"     : [NSString stringWithFormat:@"%f,%f", destination.coordinate.latitude, destination.coordinate.longitude],
                                 @"sensor"          : @"false",
                                 @"key"             : kGoogleApiKey
                                 };

    [[NetworkManager sharedManager] getRouteWithParameters:parameters completion:^(BOOL success, NSDictionary *json, NSError *error) {
        if (success) {
            GMSMutablePath *path = [GMSMutablePath path];
            NSArray *routes = json[@"routes"];
            NSDictionary *firstRoute = routes[0];
            NSDictionary *leg = firstRoute[@"legs"][0];
            NSArray *steps = leg[@"steps"];
            int stepIndex = 0;
            
            CLLocationCoordinate2D stepCoordinates[1 + [steps count] + 1];
            for (NSDictionary *step in steps) {
                NSDictionary *startLocation = [step objectForKey:@"start_location"];
                CLLocationCoordinate2D startCoordinates = [self coordinatesFromLocation:startLocation];
                stepCoordinates[++stepIndex] = startCoordinates;
                [path addCoordinate:startCoordinates];
                
                NSString *polyLinePoints = step[@"polyline"][@"points"];
                GMSPath *polyLinePath = [GMSPath pathFromEncodedPath:polyLinePoints];
                for (int i = 0; i < polyLinePath.count; i++) {
                    [path addCoordinate:[polyLinePath coordinateAtIndex:i]];
                }
                
                if ([steps count] == stepIndex) {
                    NSDictionary *endLocation = [step objectForKey:@"end_location"];
                    CLLocationCoordinate2D endCoordinates = [self coordinatesFromLocation:endLocation];
                    stepCoordinates[++stepIndex] = endCoordinates;
                    [path addCoordinate:endCoordinates];
                }
            }
            self.polyline = [GMSPolyline polylineWithPath:path];
            _polyline.strokeColor = [UIColor blueColor];
            _polyline.strokeWidth = 3.f;
            _polyline.map = mapView;
            block(YES, nil);
        } else {
            block(NO, error);
        }
    }];
}

#pragma mark - Helpers 

- (CLLocationCoordinate2D)coordinatesFromLocation:(NSDictionary *)location {
    double latitude = [[location objectForKey:@"lat"] doubleValue];
    double longitude = [[location objectForKey:@"lng"] doubleValue];
    return CLLocationCoordinate2DMake(latitude, longitude);
}

- (void)getAddressFromLocation:(Location *)location completion:(void (^)(BOOL success, NSString *address, NSError *error))block {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)[location.latitude doubleValue]
                                                            longitude:(CLLocationDegrees)[location.longitude doubleValue]];

    [geocoder reverseGeocodeLocation:targetLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            block(NO, nil, error);
            return;
        }
        CLPlacemark *placemark = placemarks.firstObject;
        if (placemark) {
            NSString *address = [NSString stringWithFormat:@"%@, %@, %@",
                                 placemark.country,
                                 placemark.locality,
                                 placemark.thoroughfare];
            block(YES, address, nil);
            return;
        }
    }];
}

@end
