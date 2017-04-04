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
                 valetLocationObjectID:(NSString *)valetLocationObjectID
                           parkAddress:(NSString *)parkAddress
                          parkLocation:(AVGeoPoint *)parkLocation
                               success:(void (^)(OrderObject *orderObject))successBlock
                                  fail:(void (^)(NSError *error))failBlock {
    OrderObject *orderObject = [OrderObject object];
    orderObject.user_object_ID = [[AVUser currentUser] objectId];
    orderObject.drop_valet_object_ID = valetObjectID;
    orderObject.drop_valet_location_object_ID = valetLocationObjectID;
    orderObject.request_park_at = [NSDate date];
    orderObject.drop_off_address = parkAddress;
    orderObject.drop_off_location = parkLocation;
    orderObject.order_status = kUserOrderStatusUserDroppingOff;
    
    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            // set valet status to busy
            ValetLocation *valetLocation = [ValetLocation objectWithObjectId:valetLocationObjectID];
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

- (void)requestingVehicleBackWithOrderObject:(OrderObject *)orderObject
                               valetObjectID:(NSString *)valetObjectID
                       valetLocationObjectID:(NSString *)valetLocationObjectID
                               returnAddress:(NSString *)returnAddress
                              returnLocation:(AVGeoPoint *)returnLocation
                                  returnTime:(NSDate *)returnTime
                                     success:(void (^)(OrderObject *orderObject))successBlock
                                        fail:(void (^)(NSError *error))failBlock{
    UserOrderStatus originOrderStatus = orderObject.order_status;
    
    orderObject.return_valet_object_ID = valetObjectID;
    orderObject.return_valet_location_object_ID = valetLocationObjectID;
    orderObject.return_address = returnAddress;
    orderObject.return_location = returnLocation;
    orderObject.request_back_at = returnTime;
    orderObject.order_status = kUserOrderStatusRequestingBack;
    
    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (successBlock) {
            // set valet status to busy
            ValetLocation *valetLocation = [ValetLocation objectWithObjectId:valetLocationObjectID];
            [valetLocation fetchInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
                if (object) {
                    if (valetLocation.valet_is_serving == nil || [valetLocation.valet_is_serving boolValue] == NO) {
                        valetLocation.valet_is_serving = @(YES);
                        [valetLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                            if (succeeded) {
                                successBlock(orderObject);
                            } else {
                                orderObject.order_status = originOrderStatus;
                                [orderObject saveInBackground];
                                failBlock(nil);
                            }
                        }];
                    } else {
                        orderObject.order_status = originOrderStatus;
                        [orderObject saveInBackground];
                        failBlock(nil);
                    }
                } else {
                    orderObject.order_status = originOrderStatus;
                    [orderObject saveInBackground];
                    failBlock(nil);
                }
            }];
        } else {
            orderObject.order_status = originOrderStatus;
            [orderObject saveInBackground];
            failBlock(nil);
        }
    }];
}

- (void)fetchOrderStatusWithObjectID:(NSString *)orderObjectID success:(void (^)(OrderObject *orderObject))successBlock fail:(void (^)(NSError *error))failBlock {
    OrderObject *orderObject = [OrderObject objectWithObjectId:orderObjectID];
    
    [orderObject fetchInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if (object && !error) {
            successBlock((OrderObject *)object);
        } else {
            failBlock(error);
        }
    }];
}

- (void)cancelAnOrderWithOrderObject:(OrderObject *)orderObject
                             success:(void (^)(OrderObject *orderObject))successBlock
                                fail:(void (^)(NSError *error))failBlock {
    orderObject.order_status = kUserOrderStatusCancel;
    
    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            successBlock(orderObject);
            
            ValetLocation *valetLocation = [ValetLocation objectWithObjectId:orderObject.drop_valet_location_object_ID];
            valetLocation.valet_is_serving = @(NO);
            [valetLocation saveInBackground];
        } else {
            failBlock(error);
        }
    }];
}

- (void)updateAnOrderWithOrderObject:(OrderObject *)orderObject
                            toStatus:(UserOrderStatus)orderStatus
                             success:(void (^)(OrderObject *orderobject))successBlock
                                fail:(void (^)(NSError *error))failBlock {
    orderObject.order_status = orderStatus;
    
    [orderObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            successBlock(orderObject);
        } else {
            failBlock(error);
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
            hasOrderBlock(objects.firstObject);
        } else if (objects && objects.count == 0) {
            noOrderBlock();
        } else {
            failBlock();
        }
    }];
}

@end
