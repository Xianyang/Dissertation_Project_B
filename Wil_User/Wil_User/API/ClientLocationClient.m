//
//  ClientLocationClient.m
//  Wil_User
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ClientLocationClient.h"

static NSString * const LocationCLientObjectID = @"wil_local_client_location_object_id";

@interface ClientLocationClient ()

@property (strong, nonatomic) ClientLocation *clientLocation;

@end

@implementation ClientLocationClient

- (void)uploadClientLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    if (self.clientLocation.objectId == nil) {
        // 1. query from the server
        AVUser *client = [AVUser currentUser];
        
        AVQuery *query = [AVQuery queryWithClassName:[ClientLocation xyClassName]];
        [query whereKey:@"client_object_ID" equalTo:client.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count == 1 && !error) {
                self.clientLocation = objects.firstObject;
                
                // 2. update location
                
                self.clientLocation.client_location = geoPoint;
                [self.clientLocation saveInBackground];
                
                // 3. save the objectID
                [self saveClientLocationObjectIDLocally:self.clientLocation.objectId];
            } else {
                // 2. create this ValetLocation object
                self.clientLocation.client_location = geoPoint;
                self.clientLocation.client_object_ID = client.objectId;
                self.clientLocation.client_first_name = [client objectForKey:@"first_name"];
                self.clientLocation.client_last_name = [client objectForKey:@"last_name"];
                self.clientLocation.client_mobile_phone_numer = client.mobilePhoneNumber;
                self.clientLocation.client_user_name = client.username;
                
                [self.clientLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        // 3. save the objectID
                        [self saveClientLocationObjectIDLocally:self.clientLocation.objectId];
                    } else {
                        
                    }
                }];
            }
        }];
    } else {
        self.clientLocation.client_location = geoPoint;
        [self.clientLocation saveInBackground];
    }

}

- (ClientLocation *)clientLocation {
    if (!_clientLocation) {
        NSString *clientLocationObjectID = [self clientLocationObjectID];
        if (clientLocationObjectID && ![clientLocationObjectID isEqualToString:@""]) {
            _clientLocation = [ClientLocation objectWithObjectId:clientLocationObjectID];
        } else {
            _clientLocation = [ClientLocation object];
        }
    }
    
    return _clientLocation;
}

- (NSString *)clientLocationObjectID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LocationCLientObjectID];
}

- (void)saveClientLocationObjectIDLocally:(NSString *)objectID {
    if ([self clientLocationObjectID] && ![[self clientLocationObjectID] isEqualToString:@""]) {
        NSLog(@"fail to save client location object id. ID already exists");
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:objectID forKey:LocationCLientObjectID];
        NSLog(@"save client location object id successfully");
    }
}

@end
