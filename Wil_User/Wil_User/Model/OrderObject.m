//
//  OrderObject.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "OrderObject.h"

@implementation OrderObject

@dynamic user_object_ID;
@dynamic drop_valet_object_ID;
@dynamic drop_valet_location_object_ID;
@dynamic return_valet_object_ID;
@dynamic return_valet_location_object_ID;
@dynamic start_at;
@dynamic finish_at;
@dynamic park_address;
@dynamic park_location;
@dynamic parked_location;
@dynamic return_address;
@dynamic return_location;
@dynamic return_Time;
@dynamic order_status;
@dynamic vehicle_plate;

+ (NSString *)parseClassName {
    return @"Order";
}

+ (NSString *)xyClassName {
    return @"Order";
}

@end
