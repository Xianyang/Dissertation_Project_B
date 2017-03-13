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
@dynamic valet_object_ID;
@dynamic start_time;
@dynamic finish_time;
@dynamic park_address;
@dynamic park_location;

+ (NSString *)parseClassName {
    return @"Order";
}

@end
