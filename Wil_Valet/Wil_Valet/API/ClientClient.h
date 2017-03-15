//
//  ClientClient.h
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClientObject.h"

@interface ClientClient : NSObject

- (void)fetchClientObjectWithObjectID:(NSString *)clientObjectID success:(void (^)(ClientObject *clientObject))successBlock fail:(void (^)(NSError *error))failBlock;

@end
