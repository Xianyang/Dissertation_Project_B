//
//  ValetObject.m
//  Wil_User
//
//  Created by xianyang on 14/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetObject.h"

@implementation ValetObject

@dynamic first_name;
@dynamic last_name;
@dynamic profile_image_url;

+ (NSString *)parseClassName {
    return @"Valet";
}

@end
