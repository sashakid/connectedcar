//
//  RouteManager.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 5/2/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CLLocation;
@class GMSMapView;
@class Location;

@interface RouteManager : NSObject

+ (RouteManager *)sharedManager;
- (void)buildRouteFrom:(CLLocation *)source to:(CLLocation *)destination inView:(GMSMapView *)mapView completion:(void(^)(BOOL success, NSError *error))block;
- (void)getAddressFromLocation:(Location *)location completion:(void (^)(BOOL success, NSString *address, NSError *error))block;

@end
