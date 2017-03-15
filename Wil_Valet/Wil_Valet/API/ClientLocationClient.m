//
//  ClientLocationClient.m
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientLocationClient.h"

static NSString * const LocationCLientObjectID = @"wil_local_client_location_object_id";

@interface ClientLocationClient ()

@property (strong, nonatomic) ClientLocation *clientLocation;

@end

@implementation ClientLocationClient

- (void)fetchClientLocationWithClientObjectID:(NSString *)clientObjectID success:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    AVQuery *query = [AVQuery queryWithClassName:[ClientLocation xyClassName]];
    [query whereKey:@"client_object_ID" equalTo:clientObjectID];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0) {
            successBlock(objects[0]);
        } else {
            failBlock(error);
        }
    }];
}

@end
