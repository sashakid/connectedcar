//
//  NetworkManager.m
//  connectedcar
//
//  Created by Alexander Yakovlev on 4/29/17.
//  Copyright © 2017 OCSICO. All rights reserved.
//

#import "NetworkManager.h"
#import <AFNetworking/AFNetworking.h>
#import "Constants.h"

@interface NetworkManager ()

@property (nonatomic, strong) AFHTTPSessionManager *requestManager;

@end

@implementation NetworkManager

+ (NetworkManager *)sharedManager {
    static NetworkManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.requestManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrlString]];
        self.requestManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.requestManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    return self;
}

#pragma mark - Global

- (void)POST:(NSString *)urlString parameters:(id)parameters withCompletion:(NetworkCompletion)block {
    [self.requestManager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)GET:(NSString *)urlString parameters:(id)parameters withCompletion:(NetworkCompletion)block {
    [self.requestManager GET:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (responseObject) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:nil];
            if (json) {
                block(YES, json, nil);
            } else {
                NSString *receivedDataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                NSError *error = [[NSError alloc] initWithDomain:kAppDomain code:-100 userInfo:@{NSLocalizedDescriptionKey : receivedDataString}];
                block(NO, nil, error);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        block(NO, nil, error);
    }];
}

#pragma mark - Public

- (void)getUsersWithCompletion:(NetworkCompletion)block {
    NSDictionary *parameters = @{@"op" : @"list"};
    [self GET:@"" parameters:parameters withCompletion:^(BOOL success, NSDictionary *json, NSError *error) {
        block(success, json, error);
    }];
}

- (void)getVehicleLocationWithUserID:(NSInteger)userID completion:(NetworkCompletion)block {
    NSDictionary *parameters = @{
                                 @"op"      : @"getlocations",
                                 @"userid"  : @(userID)
                                 };
    [self GET:@"" parameters:parameters withCompletion:^(BOOL success, NSDictionary *json, NSError *error) {
        block(success, json, error);
    }];
}

- (void)getRouteWithParameters:(NSDictionary *)parameters completion:(NetworkCompletion)block {
    [self GET:kGoogleApiUrlString parameters:parameters withCompletion:^(BOOL success, NSDictionary *json, NSError *error) {
        if (success) {
            if ([json[@"routes"] count] > 0) {
                block(YES, json, error);
                return;
            } else {
                if (json[@"status"]) {
                    error = [[NSError alloc] initWithDomain:kAppDomain code:-102 userInfo:@{NSLocalizedDescriptionKey : json[@"status"]}];
                } else {
                    error = [[NSError alloc] initWithDomain:kAppDomain code:-103 userInfo:@{NSLocalizedDescriptionKey : @"Google Directions API error"}];
                }
            }
        }
        block(NO, nil, error);
    }];
}

@end
