//
//  ValetLocationClient.h
//  Wil_Valet
//
//  Created by xianyang on 14/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValetLocation.h"

@interface ValetLocationClient : NSObject

- (void)uploadValetLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ValetLocation *valetLocation))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)saveValetLocationObjectIDLocally:(NSString *)objectID;

@end
