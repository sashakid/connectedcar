//
//  DatabaseManager.h
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import <Foundation/Foundation.h>

@class User;

typedef void(^DatabaseCompletion)(BOOL success, NSArray *result, NSError *error);

@interface DatabaseManager : NSObject

+ (DatabaseManager *)sharedManager;
- (void)getUsersWithCompletion:(DatabaseCompletion)block;
- (void)getLocationsForUserID:(NSInteger)userID completion:(DatabaseCompletion)block;

@end
