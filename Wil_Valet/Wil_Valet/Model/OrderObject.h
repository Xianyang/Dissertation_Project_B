//
//  OrderObject.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface OrderObject : AVObject

@property (nonatomic, copy) NSString *user_object_ID;
@property (nonatomic, copy) NSString *drop_valet_object_ID;
@property (nonatomic, copy) NSString *drop_valet_location_object_ID;
@property (nonatomic, copy) NSString *return_valet_object_ID;
@property (nonatomic, copy) NSString *return_valet_location_object_ID;
@property (nonatomic, copy) NSDate *request_park_at;
@property (nonatomic, copy) NSDate *drop_off_at;
@property (nonatomic, copy) NSDate *park_at;
@property (nonatomic, copy) NSDate *request_back_at;
@property (nonatomic, copy) NSDate *return_at;
@property (nonatomic, copy) NSDate *pay_at;
@property (nonatomic, copy) NSString *park_address;
@property (nonatomic, copy) AVGeoPoint *park_location;
@property (nonatomic, copy) AVGeoPoint *parked_location;
@property (nonatomic, copy) NSString *return_address;
@property (nonatomic, copy) AVGeoPoint *return_location;
@property int order_status;
@property (nonatomic, copy) NSString *vehicle_plate;
@property (nonatomic, copy) NSNumber *payment_amount;

+ (NSString *)xyClassName;

@end
