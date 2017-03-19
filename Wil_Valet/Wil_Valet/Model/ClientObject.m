//
//  ClientObject.m
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientObject.h"

@implementation ClientObject

@dynamic last_name;
@dynamic first_name;
@dynamic profile_image_url;

+ (NSString *)parseClassName {
    return @"Client";
}

@end
