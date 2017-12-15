//
//  User.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Owner.h"
#import "Vehicle.h"
#import "Location.h"

@interface User : NSManagedObject

@property (nonatomic, strong) NSDate *sync;
@property (nonatomic, strong) NSNumber *userID;
@property (nonatomic, strong) Owner *owner;
@property (nonatomic, strong) NSSet<Vehicle *> *vehicles;

- (void)addVehicles:(NSSet *)objects;

@end
