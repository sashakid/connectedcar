//
//  Location.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Vehicle;

@interface Location : NSManagedObject

@property (nonatomic, strong) NSDate *sync;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) Vehicle *vehicle;

@end
