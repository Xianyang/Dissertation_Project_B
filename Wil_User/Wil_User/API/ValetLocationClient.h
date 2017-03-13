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

- (void)fetchValetsLocationsSuccessful:(void (^)(NSArray *array))successBlock fail:(void (^)(NSError *error))failBlock;
- (NSArray *)valetLocations;
- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate;

@end
