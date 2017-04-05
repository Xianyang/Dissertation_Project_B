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
@dynamic request_park_at;
@dynamic drop_off_at;
@dynamic park_at;
@dynamic request_back_at;
@dynamic return_at;
@dynamic pay_at;
@dynamic drop_off_address;
@dynamic drop_off_location;
@dynamic parked_location;
@dynamic return_address;
@dynamic return_location;
@dynamic order_status;
@dynamic vehicle_image_url;
@dynamic vehicle_plate;
@dynamic vehicle_model;
@dynamic vehicle_color;
@dynamic payment_amount;

+ (NSString *)parseClassName {
    return @"Order";
}

+ (NSString *)xyClassName {
    return @"Order";
}

@end
