//
//  ValetLocationClient.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetLocationClient.h"

@interface ValetLocationClient ()

@property (strong, nonatomic) NSArray * valetLocations;

@end

@implementation ValetLocationClient

- (void)fetchValetsLocationsSuccessful:(void (^)(NSArray *array))successBlock fail:(void (^)(NSError *error))failBlock {
    NSMutableArray *locations = [NSMutableArray array];
    
    AVQuery *query = [AVQuery queryWithClassName:[ValetLocation parseClassName]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0 && !error) {
            for (AVObject *object in objects) {
                NSInteger timerinterval = [[NSDate date] timeIntervalSinceDate:object.updatedAt];
                NSLog(@"time interval %ld", (long)timerinterval);
                
                ValetLocation *valetLocation = (ValetLocation *)object;
                
                // filter valet locations based on 1. update time 2. is serving status
                if ([[NSDate date] timeIntervalSinceDate:valetLocation.updatedAt] <= 30000 && ![valetLocation.valet_is_serving boolValue]) {
                    [locations addObject:valetLocation];
                }
            }
            
            self.valetLocations = locations;
            successBlock(locations);
        } else {
            failBlock(error);
        }
    }];
}

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate {
    CLLocation *userLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    CLLocationDistance nearestDistance = CLLocationDistanceMax;
    ValetLocation *nearestValetLocation = nil;
    
    for (ValetLocation *valetLocation in self.valetLocations) {
        CLLocation *valetCLLocation = [[CLLocation alloc] initWithLatitude:valetLocation.valet_location.latitude longitude:valetLocation.valet_location.longitude];
        CLLocationDistance tempDistance = [userLocation distanceFromLocation:valetCLLocation];
        if (tempDistance < nearestDistance) {
            nearestDistance = tempDistance;
            nearestValetLocation = valetLocation;
        }
    }
    
    return nearestValetLocation;
}

- (NSArray *)valetLocations {
    if (!_valetLocations) {
        _valetLocations = [[NSArray alloc] init];
    }
    
    return _valetLocations;
}

@end
