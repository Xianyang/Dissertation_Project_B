//
//  ValetLocation.h
//  Wil_Valet
//
//  Created by xianyang on 12/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface ValetLocation : AVObject <AVSubclassing>

@property (nonatomic, copy) NSString *valet_object_ID;
@property (nonatomic, copy) NSString *valet_user_name;
@property (nonatomic, copy) NSString *valet_first_name;
@property (nonatomic, copy) NSString *valet_last_name;
@property (nonatomic, copy) NSString *valet_mobile_phone_numer;
@property (nonatomic, copy) AVGeoPoint *valet_location;

@end
