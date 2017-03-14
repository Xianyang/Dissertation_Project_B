//
//  ValetLocationClient.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetLocationClient.h"

@interface ValetLocationClient ()

@end

@implementation ValetLocationClient

- (void)fetchValetsLocationsWithStatus:(UserOrderStatus)userOrderStatus
                           orderObject:(OrderObject *)orderObject
                          valetMarkers:(NSArray *)valetMarkers
                               success:(void (^)(NSArray *array))successBlock
                                  fail:(void (^)(NSError *error))failBlock {
    
    AVQuery *query = [AVQuery queryWithClassName:[ValetLocation parseClassName]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0 && !error) {
            // 1. fitler valet locations
            [self filterValetLocations:objects];
            
            // 2. check order status
            if (userOrderStatus == kUserOrderStatusNone || userOrderStatus == kUserOrderStatusParked) {
                successBlock(self.availableValetLocations);
            } else if (userOrderStatus == kUserOrderStatusUserDroppingOff || userOrderStatus == kUserOrderStatusParking) {
                // get the working valet
                self.dropValetLocation = [self generateDropVehicleValet:self.onlineValetLocations orderObject:orderObject];
                if (self.dropValetLocation) {
                    successBlock(@[self.dropValetLocation]);
                } else {
                    failBlock(nil);
                }
            } else if (userOrderStatus == kUserOrderStatusRequestingBack) {
                // get the working valet
                self.returnValetLocation = [self generateDropVehicleValet:self.onlineValetLocations orderObject:orderObject];
                if (self.returnValetLocation) {
                    successBlock(@[self.returnValetLocation]);
                } else {
                    failBlock(nil);
                }
            } else {
                failBlock(nil);
            }
            
        } else {
            failBlock(error);
        }
    }];
}

- (void)filterValetLocations:(NSArray *)valetLocations {
    [self.onlineValetLocations removeAllObjects];
    [self.availableValetLocations removeAllObjects];
    [self.busyValetLocations removeAllObjects];
    
    for (ValetLocation *valetLocation in valetLocations) {
        NSInteger timeInterval = [[NSDate date] timeIntervalSinceDate:valetLocation.updatedAt];
        NSLog(@"time interval is %ld for %@", (long)timeInterval, valetLocation.valet_first_name);
        if (timeInterval <= 30000) {
            [self.onlineValetLocations addObject:valetLocation];
            
            // check if the valet is busy or free
            if ([valetLocation.valet_is_serving boolValue]) {
                [self.busyValetLocations addObject:valetLocation];
            } else {
                [self.availableValetLocations addObject:valetLocation];
            }
        }
    }
}

- (ValetLocation *)generateDropVehicleValet:(NSArray *)valetLocations orderObject:(OrderObject *)orderObject{
    for (ValetLocation *valetLocation in valetLocations) {
        if ([valetLocation.valet_object_ID isEqualToString:orderObject.drop_valet_object_ID]) {
            return valetLocation;
        }
    }
    
    return nil;
}

- (ValetLocation *)generateReturnVehicleValet:(NSArray *)valetLocations orderObject:(OrderObject *)orderObject {
    for (ValetLocation *valetLocation in valetLocations) {
        if ([valetLocation.valet_object_ID isEqualToString:orderObject.return_valet_object_ID]) {
            return valetLocation;
        }
    }
    
    return nil;
}

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate {
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocationDistance nearestDistance = CLLocationDistanceMax;
    ValetLocation *nearestValetLocation = nil;
    
    for (ValetLocation *valetLocation in self.availableValetLocations) {
        CLLocation *valetCLLocation = [[CLLocation alloc] initWithLatitude:valetLocation.valet_location.latitude longitude:valetLocation.valet_location.longitude];
        CLLocationDistance tempDistance = [userLocation distanceFromLocation:valetCLLocation];
        if (tempDistance < nearestDistance) {
            nearestDistance = tempDistance;
            nearestValetLocation = valetLocation;
        }
    }
    
    return nearestValetLocation;
}

- (NSMutableArray *)onlineValetLocations {
    if (!_onlineValetLocations) {
        _onlineValetLocations = [[NSMutableArray alloc] init];
    }
    
    return _onlineValetLocations;
}

- (NSMutableArray *)availableValetLocations {
    if (!_availableValetLocations) {
        _availableValetLocations = [[NSMutableArray alloc] init];
    }
    
    return _availableValetLocations;
}

- (NSMutableArray *)busyValetLocations {
    if (!_busyValetLocations) {
        _busyValetLocations = [[NSMutableArray alloc] init];
    }
    
    return _busyValetLocations;
}

@end
