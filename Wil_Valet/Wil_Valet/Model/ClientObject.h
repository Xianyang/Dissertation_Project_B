//
//  ClientObject.h
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>

@interface ClientObject : AVObject

@property (nonatomic, copy) NSString *last_name;
@property (nonatomic, copy) NSString *first_name;
@property (nonatomic, copy) NSString *profile_image_url;

@end
