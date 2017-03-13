//
//  OrderClient.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "OrderClient.h"

@implementation OrderClient

- (void)createAnOrderWithValetObjectID:(NSString *)valetObjectID
                           parkAddress:(NSString *)parkAddress
                          parkLocation:(AVGeoPoint *)parkLocation
                               success:(void (^)(OrderObject *orderObject))successBlock
                                  fail:(void (^)(NSError *error))failBlock {
    OrderObject *orderObject = [OrderObject object];
    orderObject.user_object_ID = [[AVUser currentUser] objectId];
    orderObject.valet_object_ID = valetObjectID;
    orderObject.start_at = [NSDate date];
    orderObject.park_address = parkAddress;
    orderObject.park_location = parkLocation;
    orderObject.order_status = kUserOrderStatusUserDroppingOff;
    
    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // set valet status to busy
            ValetLocation *valetLocation = [ValetLocation objectWithObjectId:valetObjectID];
            [valetLocation fetchInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
                if (object) {
                    if (valetLocation.valet_is_serving == nil || [valetLocation.valet_is_serving boolValue] == NO) {
                        valetLocation.valet_is_serving = @(YES);
                        [valetLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (succeeded) {
                                successBlock(orderObject);
                            } else {
                                [orderObject deleteInBackground];
                                failBlock(nil);
                            }
                        }];
                    } else {
                        [orderObject deleteInBackground];
                        failBlock(nil);
                    }
                } else {
                    [orderObject deleteInBackground];
                    failBlock(nil);
                }
            }];
        } else {
            [orderObject deleteInBackground];
            failBlock(nil);
        }
    }];
}

- (void)checkIfUserHasUnfinishedOrder:(void (^)(OrderObject *))hasOrderBlock noOrder:(void (^)())noOrderBlock fail:(void (^)())failBlock {
    AVQuery *userObjectIDQuery = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [userObjectIDQuery whereKey:@"user_object_ID" equalTo:[[AVUser currentUser] objectId]];
    
    AVQuery *orderStatusQueryLowLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryLowLimit whereKey:@"order_status" greaterThan:@(kUserOrderStatusNone)];
    
    AVQuery *orderStatusQueryHighLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryHighLimit whereKey:@"order_status" lessThan:@(kUserOrderStatusFinished)];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[userObjectIDQuery, orderStatusQueryLowLimit, orderStatusQueryHighLimit]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0) {
            hasOrderBlock(objects[0]);
        } else if (objects && objects.count == 0) {
            noOrderBlock();
        } else {
            failBlock();
        }
    }];
}

@end
