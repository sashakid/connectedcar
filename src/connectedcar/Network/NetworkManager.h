//
//  NetworkManager.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^NetworkCompletion)(BOOL success, NSDictionary *json, NSError *error);

@interface NetworkManager : NSObject

+ (NetworkManager *)sharedManager;
- (void)getUsersWithCompletion:(NetworkCompletion)block;
- (void)getVehicleLocationWithUserID:(NSInteger)userID completion:(NetworkCompletion)block;
- (void)getRouteWithParameters:(NSDictionary *)parameters completion:(NetworkCompletion)block;

@end
