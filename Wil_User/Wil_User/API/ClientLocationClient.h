//
//  ClientLocationClient.h
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientLocation.h"

@interface ClientLocationClient : NSObject

- (void)uploadClientLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)saveClientLocationObjectIDLocally:(NSString *)objectID;

@end
