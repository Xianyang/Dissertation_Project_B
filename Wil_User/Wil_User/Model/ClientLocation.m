//
//  ClientLocation.m
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientLocation.h"

@implementation ClientLocation

@dynamic client_object_ID;
@dynamic client_user_name;
@dynamic client_first_name;
@dynamic client_last_name;
@dynamic client_mobile_phone_numer;
@dynamic client_location;

+ (NSString *)parseClassName {
    return @"Client_Location";
}

+ (NSString *)xyClassName {
    return [ClientLocation parseClassName];
}

@end
