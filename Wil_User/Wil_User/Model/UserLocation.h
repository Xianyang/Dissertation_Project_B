//
//  UserLocation.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface UserLocation : AVObject

@property (nonatomic, copy) NSString *user_object_ID;
@property (nonatomic, copy) NSString *user_user_name;
@property (nonatomic, copy) NSString *user_first_name;
@property (nonatomic, copy) NSString *user_last_name;
@property (nonatomic, copy) NSString *user_mobile_phone_numer;
@property (nonatomic, copy) AVGeoPoint *user_location;

@end
