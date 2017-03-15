//
//  ClientLocation.m
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientLocation.h"

@implementation ClientLocation

@dynamic user_object_ID;
@dynamic user_user_name;
@dynamic user_first_name;
@dynamic user_last_name;
@dynamic user_mobile_phone_numer;
@dynamic user_location;

+ (NSString *)parseClassName {
    return @"Client_Location";
}

@end
