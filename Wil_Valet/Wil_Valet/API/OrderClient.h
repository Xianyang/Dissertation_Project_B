//
//  OrderClient.h
//  Wil_Valet
//
//  Created by xianyang on 14/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderClient : NSObject

- (void)fetchCurrentOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)fetchCurrentDropOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)fetchCurrentReturnOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock;

@end
