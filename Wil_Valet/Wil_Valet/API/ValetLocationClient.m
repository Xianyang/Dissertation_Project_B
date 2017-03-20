//
//  ValetLocationClient.m
//  Wil_Valet
//
//  Created by xianyang on 14/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetLocationClient.h"
#import "ASIHTTPRequest.h"

static NSString * const LocationObjectName = @"wil_local_valet_location_object_id";

@interface ValetLocationClient ()

@property (strong, nonatomic) ValetLocation *valetLocation;

@end

@implementation ValetLocationClient

- (void)uploadValetLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ValetLocation *valetLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    if (self.valetLocation.objectId == nil) {
        // 1. query from the server
        AVUser *valet = [AVUser currentUser];
        
        AVQuery *query = [AVQuery queryWithClassName:[ValetLocation parseClassName]];
        [query whereKey:@"valet_object_ID" equalTo:valet.objectId];
        [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
            if (objects.count == 1 && !error) {
                self.valetLocation = objects[0];
                
                // 2. update location
                
                self.valetLocation.valet_location = geoPoint;
                [self.valetLocation saveInBackground];
                
                // 3. save the objectID
                [self saveValetLocationObjectIDLocally:self.valetLocation.objectId];
            } else {
                // 2. create this ValetLocation object
                self.valetLocation.valet_location = geoPoint;
                self.valetLocation.valet_object_ID = valet.objectId;
                self.valetLocation.valet_first_name = [valet objectForKey:@"first_name"];
                self.valetLocation.valet_last_name = [valet objectForKey:@"last_name"];
                self.valetLocation.valet_mobile_phone_numer = valet.mobilePhoneNumber;
                self.valetLocation.valet_user_name = valet.username;
                
                [self.valetLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (succeeded) {
                        // 3. save the objectID
                        [self saveValetLocationObjectIDLocally:self.valetLocation.objectId];
                    } else {
                        
                    }
                }];
            }
        }];
    } else {
        self.valetLocation.valet_location = geoPoint;
        [self.valetLocation saveInBackground];
    }
}

- (void)getRouteWithMyLocation:(CLLocation *)myLocation destinationLocation:(CLLocation *)destinationLocation success:(void (^)(GMSPolyline *route))successBlock fail:(void (^)(NSError *error))failBlock {
    NSString *urlString = [NSString stringWithFormat:
                           @"%@?origin=%f,%f&destination=%f,%f&sensor=true&key=%@",
                           @"https://maps.googleapis.com/maps/api/directions/json",
                           myLocation.coordinate.latitude,
                           myLocation.coordinate.longitude,
                           destinationLocation.coordinate.latitude,
                           destinationLocation.coordinate.longitude,
                           @"AIzaSyAt1lC0x7LA89ssDNdw5tv1jL7SUEbojC0"];
    NSURL *directionsURL = [NSURL URLWithString:urlString];
    
    ASIHTTPRequest *req = [ASIHTTPRequest requestWithURL:directionsURL];
    [req startSynchronous];
    NSError *error = [req error];
    if (!error) {
        NSString *response = [req responseString];
        NSLog(@"%@",response);
        NSDictionary *json =[NSJSONSerialization JSONObjectWithData:[req responseData] options:NSJSONReadingMutableContainers error:&error];
        GMSPath *path =[GMSPath pathFromEncodedPath:json[@"routes"][0][@"overview_polyline"][@"points"]];
        GMSPolyline *singleLine = [GMSPolyline polylineWithPath:path];
        singleLine.strokeWidth = 7;
        singleLine.strokeColor = [UIColor colorWithRed:90.0f / 255.0f green:150.0f / 255.0f blue:245.0f / 255.0f alpha:1];
        successBlock(singleLine);
    } else {
        failBlock(error);
    }
}

- (void)updateValetServingStatus:(BOOL)isServing{
    self.valetLocation.valet_is_serving = @(isServing);
    
    [self.valetLocation saveInBackground];
}

- (ValetLocation *)valetLocation {
    if (!_valetLocation) {
        NSString *valetLocationObjectID = [self valetLocationObjectID];
        if (valetLocationObjectID && ![valetLocationObjectID isEqualToString:@""]) {
            _valetLocation = [ValetLocation objectWithObjectId:valetLocationObjectID];
        } else {
            _valetLocation = [ValetLocation object];
        }
    }
    
    return _valetLocation;
}

- (NSString *)valetLocationObjectID {
    return [[NSUserDefaults standardUserDefaults] objectForKey:LocationObjectName];
}

- (void)saveValetLocationObjectIDLocally:(NSString *)objectID {
    if ([self valetLocationObjectID] && ![[self valetLocationObjectID] isEqualToString:@""]) {
        NSLog(@"fail to save valet location object id. ID already exists");
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:objectID forKey:LocationObjectName];
        NSLog(@"save valet location object id successfully");
    }
}

@end
