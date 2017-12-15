//
//  DatabaseManager.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "DatabaseManager.h"
#import <MagicalRecord/MagicalRecord.h>
#import "User.h"
#import "NetworkManager.h"
#import "Constants.h"
#import "DateTools.h"
#import "RouteManager.h"

@implementation DatabaseManager

#pragma mark - Private

- (void)saveContext {
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
            NSLog(@"Error saving context: %@", error.description);
        }
    }];
}

- (void)saveUserFromJSON:(NSDictionary *)json {
    User *user = [User MR_createEntity];
    user.userID = json[@"userid"];
    user.sync = [NSDate date];
    
    Owner *owner = [Owner MR_createEntity];
    owner.name = json[@"owner"][@"name"];
    owner.surname = json[@"owner"][@"surname"];
    owner.photoURL = json[@"owner"][@"foto"];
    user.owner = owner;
    
    NSMutableSet *vehicles = [[NSMutableSet alloc] init];
    for (NSDictionary *vehicleDictionary in json[@"vehicles"]) {
        Vehicle *vehicle = [Vehicle MR_createEntity];
        vehicle.vehicleID = vehicleDictionary[@"vehicleid"];
        vehicle.make = vehicleDictionary[@"make"];
        vehicle.model = vehicleDictionary[@"model"];
        vehicle.year = @([vehicleDictionary[@"year"] integerValue]);
        vehicle.color = vehicleDictionary[@"color"];
        vehicle.vin = vehicleDictionary[@"vin"];
        vehicle.photoURL = vehicleDictionary[@"foto"];
        [vehicles addObject:vehicle];
    }
    [user addVehicles:vehicles];
    [self saveContext];
}

- (void)saveLocationFromJSON:(NSDictionary *)json {
    Location *location = [Location MR_createEntity];
    Vehicle *vehicle = [Vehicle MR_findFirstByAttribute:@"vehicleID" withValue:json[@"vehicleid"]];
    location.vehicle = vehicle;
    location.longitude = json[@"lon"];
    location.latitude = json[@"lat"];
    location.sync = [NSDate date];
    [self saveContext];

    [[RouteManager sharedManager] getAddressFromLocation:vehicle.location completion:^(BOOL success, NSString *address, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                Location *location = [Location MR_findFirstByAttribute:@"vehicle.vehicleID" withValue:json[@"vehicleid"]];
                location.address = address;
                [self saveContext];
            }
        });
    }];
}

#pragma mark - Public

+ (DatabaseManager *)sharedManager {
    static DatabaseManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (void)getUsersWithCompletion:(DatabaseCompletion)block {
    if ([self isUserShouldSynced]) {
        [[NetworkManager sharedManager] getUsersWithCompletion:^(BOOL success, NSDictionary *json, NSError *error) {
            if (success) {
                //before sync we should delete all users from DB
                [User MR_truncateAll];
                
                for (NSDictionary *data in json[@"data"]) {
                    if ([[data allKeys] count] > 0) {
                        [self saveUserFromJSON:data];
                    }
                }
                NSArray *result = [User MR_findAll];
                if ([result count] > 0) {
                    block(YES, result, nil);
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Database error"}];
                    block(NO, nil, error);
                }
            } else {
                block(NO, nil, error);
            }
        }];
    } else {
        NSArray *result = [User MR_findAll];
        if ([result count] > 0) {
            block(YES, result, nil);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Database error"}];
            block(NO, nil, error);
        }
    }
}

- (void)getLocationsForUserID:(NSInteger)userID completion:(DatabaseCompletion)block {
    if ([self isLocationShouldSyncedForUserID:userID]) {
        [[NetworkManager sharedManager] getVehicleLocationWithUserID:userID completion:^(BOOL success, NSDictionary *json, NSError *error) {
            if (success) {
                //before sync we should delete all previous locations of this user from DB
                NSArray *search = [Location MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(SELF.vehicle.user.userID == %li)", userID]];
                for (Location *location in search) {
                    [location MR_deleteEntity];
                }
                
                for (NSDictionary *data in json[@"data"]) {
                    if ([[data allKeys] count] > 0) {
                        if (!data[@"lon"] || !data[@"lat"]) {
                            NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-105 userInfo:@{NSLocalizedDescriptionKey : @"No location received"}];
                            block(NO, nil, error);
                            return;
                        }
                        [self saveLocationFromJSON:data];
                    }
                }
                User *user = [User MR_findFirstByAttribute:@"userID" withValue:@(userID)];
                NSMutableArray *locations = [[NSMutableArray alloc] init];
                for (Vehicle *vehicle in user.vehicles) {
                    [locations addObject:vehicle.location];
                }
                NSArray *result = [locations copy];
                if ([result count] > 0) {
                    block(YES, result, nil);
                } else {
                    NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Database error"}];
                    block(NO, nil, error);
                }
            } else {
                block(NO, nil, error);
            }
        }];
    } else {
        User *user = [User MR_findFirstByAttribute:@"userID" withValue:@(userID)];
        NSMutableArray *locations = [[NSMutableArray alloc] init];
        for (Vehicle *vehicle in user.vehicles) {
            [locations addObject:vehicle.location];
        }
        NSArray *result = [locations copy];
        if ([result count] > 0) {
            block(YES, result, nil);
        } else {
            NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-101 userInfo:@{NSLocalizedDescriptionKey : @"Database error"}];
            block(NO, nil, error);
        }
    }
}

#pragma mark - Private

- (BOOL)isUserShouldSynced {
    NSArray *result = [User MR_findAll];
    if (result.count > 0) {
        User *user = result[0];
        NSDate *dateBefore = [[NSDate date] dateBySubtractingDays:kSyncUserInDays];
        if ([dateBefore isEarlierThan:user.sync]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)isLocationShouldSyncedForUserID:(NSInteger)userID {
    NSArray *result = [Location MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"(SELF.vehicle.user.userID == %li)", userID]];
    if (result.count > 0) {
        Location *location = result[0];
        NSDate *dateBefore = [[NSDate date] dateBySubtractingSeconds:kSyncLocationInSeconds];
        if ([dateBefore isEarlierThan:location.sync]) {
            return NO;
        }
    }
    return YES;
}

@end
