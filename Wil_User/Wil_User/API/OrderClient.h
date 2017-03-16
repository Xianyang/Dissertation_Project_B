//
//  OrderClient.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderObject.h"

@interface OrderClient : NSObject

- (void)createAnOrderWithValetObjectID:(NSString *)valetObjectID
                 valetLocationObjectID:(NSString *)valetLocationObjectID
                           parkAddress:(NSString *)parkAddress
                          parkLocation:(AVGeoPoint *)parkLocation
                               success:(void (^)(OrderObject *orderObject))successBlock
                                  fail:(void (^)(NSError *error))failBlock;

- (void)requestingVehicleBackWithOrderObject:(OrderObject *)orderObject
                               valetObjectID:(NSString *)valetObjectID
                       valetLocationObjectID:(NSString *)valetLocationObjectID
                               returnAddress:(NSString *)returnAddress
                              returnLocation:(AVGeoPoint *)returnLocation
                                  returnTime:(NSDate *)returnTime
                                     success:(void (^)(OrderObject *orderObject))successBlock
                                        fail:(void (^)(NSError *error))failBlock;

- (void)cancelAnOrderWithOrderObject:(OrderObject *)orderObject
                             success:(void (^)(OrderObject *orderObject))successBlock
                                fail:(void (^)(NSError *error))failBlock;



- (void)checkIfUserHasUnfinishedOrder:(void (^)(OrderObject *orderObject))hasOrderBlock noOrder:(void(^)())noOrderBlock fail:(void (^)())failBlock;

- (void)fetchOrderStatusWithObjectID:(NSString *)orderObjectID success:(void (^)(OrderObject *orderObject))successBlock fail:(void (^)(NSError *error))failBlock;



@end
