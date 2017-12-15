//
//  Vehicle.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Location;
@class User;

@interface Vehicle : NSManagedObject

@property (nonatomic, strong) NSString *color;
@property (nonatomic, strong) NSString *make;
@property (nonatomic, strong) NSString *model;
@property (nonatomic, strong) NSString *photoURL;
@property (nonatomic, strong) NSNumber *vehicleID;
@property (nonatomic, strong) NSString *vin;
@property (nonatomic, strong) NSNumber *year;
@property (nonatomic, strong) Location *location;
@property (nonatomic, strong) User *user;

@end
