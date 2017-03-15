//
//  OrderObject.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ValetLocation.h"

@interface OrderObject : AVObject

@property (nonatomic, copy) NSString *user_object_ID;
@property (nonatomic, copy) NSString *drop_valet_object_ID;
@property (nonatomic, copy) NSString *drop_valet_location_object_ID;
@property (nonatomic, copy) NSString *return_valet_object_ID;
@property (nonatomic, copy) NSString *return_valet_location_object_ID;
@property (nonatomic, copy) NSDate *start_at;
@property (nonatomic, copy) NSDate *finish_at;
@property (nonatomic, copy) NSString *park_address;
@property (nonatomic, copy) AVGeoPoint *park_location;
@property int order_status;
@property (nonatomic, copy) NSString *vehicle_plate;

+ (NSString *)xyClassName;

@end
