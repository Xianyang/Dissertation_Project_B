//
//  ClientLocation.h
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface ClientLocation : AVObject

@property (nonatomic, copy) NSString *client_object_ID;
@property (nonatomic, copy) NSString *client_user_name;
@property (nonatomic, copy) NSString *client_first_name;
@property (nonatomic, copy) NSString *client_last_name;
@property (nonatomic, copy) NSString *client_mobile_phone_numer;
@property (nonatomic, copy) AVGeoPoint *client_location;

+ (NSString *)xyClassName;

@end
