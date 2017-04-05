//
//  ValetLocationClient.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValetLocation.h"

@interface ValetLocationClient : NSObject

@property (strong, nonatomic) NSMutableArray * onlineValetLocations;
@property (strong, nonatomic) NSMutableArray * availableValetLocations;
@property (strong, nonatomic) NSMutableArray * busyValetLocations;
@property (strong, nonatomic) ValetLocation * dropValetLocation;
@property (strong, nonatomic) ValetLocation * returnValetLocation;

- (void)fetchValetsLocationsWithStatus:(UserOrderStatus)userOrderStatus
                           orderObject:(OrderObject *)orderObject
                          valetMarkers:(NSArray *)valetMarkers
                               success:(void (^)(NSArray *array))successBlock
                                  fail:(void (^)(NSError *error))failBlock;

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate;
- (NSString *)timeFromValetLocationToMeetLocation:(NSString *)valetObjectID meetLocation:(CLLocation *)meetLocation;

@end
