//
//  ValetLocation.m
//  Wil_Valet
//
//  Created by xianyang on 12/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetLocation.h"

@implementation ValetLocation

@dynamic valet_object_ID;
@dynamic valet_user_name;
@dynamic valet_first_name;
@dynamic valet_last_name;
@dynamic valet_mobile_phone_numer;
@dynamic valet_location;
@dynamic valet_is_serving;

+ (NSString *)parseClassName {
    return @"Valet_Location";
}

@end
