//
//  OrderClient.m
//  Wil_Valet
//
//  Created by xianyang on 14/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "OrderClient.h"
#import "OrderObject.h"

@implementation OrderClient

- (void)fetchCurrentDropOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock {
    AVQuery *valetObjectIDQuery = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [valetObjectIDQuery whereKey:@"drop_valet_object_ID" equalTo:[[AVUser currentUser] objectId]];
    
    AVQuery *orderStatusQueryLowLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryLowLimit whereKey:@"order_status" greaterThan:@(kUserOrderStatusNone)];
    
    AVQuery *orderStatusQueryHighLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryHighLimit whereKey:@"order_status" lessThan:@(kUserOrderStatusParked)];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[valetObjectIDQuery, orderStatusQueryLowLimit, orderStatusQueryHighLimit]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0 && !error) {
            successBlock(objects);
        } else {
            failBlock(error);
        }
    }];
}

- (void)fetchCurrentReturnOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock {
    AVQuery *valetObjectIDQuery = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [valetObjectIDQuery whereKey:@"return_valet_object_ID" equalTo:[[AVUser currentUser] objectId]];
    
    AVQuery *orderStatusQueryLowLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryLowLimit whereKey:@"order_status" greaterThan:@(kUserOrderStatusParked)];
    
    AVQuery *orderStatusQueryHighLimit = [AVQuery queryWithClassName:[OrderObject xyClassName]];
    [orderStatusQueryHighLimit whereKey:@"order_status" lessThan:@(kUserOrderStatusPaymentPending)];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[valetObjectIDQuery, orderStatusQueryLowLimit, orderStatusQueryHighLimit]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0 && !error) {
            successBlock(objects);
        } else {
            failBlock(error);
        }
    }];
}


@end
