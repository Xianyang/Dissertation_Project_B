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

//- (void)transferProperty:(AVObject *)object {
//    self.valet_object_ID = [object objectForKey:@"valet_object_ID"];
//    self.valet_user_name = [object objectForKey:@"valet_user_name"];
//    self.valet_first_name = [object objectForKey:@"valet_first_name"];
//    self.valet_last_name = [object objectForKey:@"valet_last_name"];
//    self.valet_mobile_phone_numer = [object objectForKey:@"valet_mobile_phone_numer"];
//    self.valet_location = [object objectForKey:@"valet_location"];
//    self.valet_is_serving = [object objectForKey:@"valet_is_serving"];
//}

//- (id)initWithValetObjectID:(NSString *)valetObjectID
//              valetUserName:(NSString *)valetUserName
//             valetFirstName:(NSString *)valetFirstName
//              valetLastName:(NSString *)valetLastName
//     valetMobilePhoneNumber:(NSString *)valetMobilePhoneNumer
//              valetLocation:(AVGeoPoint *)valetLocation
//            valetIsServiing:(NSNumber *)valetIsServing {
//    self = [super init];
//    
//    if (self) {
//        self.valet_object_ID = valetObjectID;
//        self.valet_user_name = valetUserName;
//        self.valet_first_name = valetFirstName;
//        self.valet_last_name = valetLastName;
//        self.valet_mobile_phone_numer = valetMobilePhoneNumer;
//        self.valet_location = valetLocation;
//        self.valet_is_serving = valetIsServing;
//    }
//    
//    return self;
//}
//
//- (id)initWithAVObject:(AVObject *)object {
//    self = [super init];
//    
//    if (self) {
//        self.valet_object_ID = [object objectForKey:@"valet_object_ID"];
//        self.valet_user_name = [object objectForKey:@"valet_user_name"];
//        self.valet_first_name = [object objectForKey:@"valet_first_name"];
//        self.valet_last_name = [object objectForKey:@"valet_last_name"];
//        self.valet_mobile_phone_numer = [object objectForKey:@"valet_mobile_phone_numer"];
//        self.valet_location = [object objectForKey:@"valet_location"];
//        self.valet_is_serving = [object objectForKey:@"valet_is_serving"];
//        if (self.valet_is_serving == nil) {
//            self.valet_is_serving = @(NO);
//        }
//    }
//    
//    return self;
//}

+ (NSString *)parseClassName {
    return @"Valet_Location";
}

@end
