//
//  ClientClient.m
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientClient.h"

@interface ClientClient ()

@property (strong, nonatomic) NSMutableArray *clients;

@end

@implementation ClientClient

- (void)fetchClientObjectWithObjectID:(NSString *)clientObjectID success:(void (^)(ClientObject *clientObject))successBlock fail:(void (^)(NSError *error))failBlock {
    ClientObject *clientObject = [ClientObject objectWithObjectId:clientObjectID];
    ClientObject *tempClientObject = [self findClientObject:clientObject];
    
    if (tempClientObject) {
        successBlock(tempClientObject);
    } else {
        [clientObject fetchIfNeededInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (object && !error) {
                [self.clients addObject:(ClientObject *)object];
                successBlock((ClientObject *)object);
            } else {
                failBlock(error);
            }
        }];
    }
}

- (ClientObject *)findClientObject:(ClientObject *)clientObject {
    for (ClientObject *savedClientObject in self.clients) {
        if ([savedClientObject.objectId isEqualToString:clientObject.objectId]) {
            return savedClientObject;
        }
    }
    
    return nil;
}

- (ClientObject *)clientObjectWithObjectID:(NSString *)clientObjectID {
    for (ClientObject *clientObject in self.clients) {
        if ([clientObject.objectId isEqualToString:clientObjectID]) {
            return clientObject;
        }
    }
    
    return nil;
}

- (NSMutableArray *)clients {
    if (!_clients) {
        _clients = [[NSMutableArray alloc] init];
    }
    
    return _clients;
}

@end
