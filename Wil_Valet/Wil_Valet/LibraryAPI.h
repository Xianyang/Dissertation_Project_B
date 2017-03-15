//
//  LibraryAPI.h
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "ValetLocation.h"
#import "ClientObject.h"

@interface LibraryAPI : NSObject

typedef enum {
    // undefine
    kUserOrderStatusUndefine = 0,
    
    // no order
    kUserOrderStatusNone,
    
    // user is dropping off its vehicle
    kUserOrderStatusUserDroppingOff,
    
    // valet is parking user's vehicle
    kUserOrderStatusParking,
    
    // valet already parked user's vehicle
    kUserOrderStatusParked,
    
    // user is requesting its vehicle
    kUserOrderStatusRequestingBack,
    
    // the order is finished
    kUserOrderStatusFinished,
    
    // the order is cancel
    kUserOrderStatusCancel
} UserOrderStatus;


+ (LibraryAPI *)sharedInstance;

// limit for user's registration
- (NSInteger)maxLengthForPhoneNumber;
- (NSInteger)minLengthForPhoneNumber;
- (NSInteger)maxLengthForVerificationCode;
- (NSInteger)maxLengthForPassword;
- (NSInteger)minLengthForPassword;
- (NSString *)phonePrefix;

// color
- (UIColor *)themeBlueColor;
- (UIColor *)themeLightBlueColor;

// Valet Location
- (void)uploadValetLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ValetLocation *valetLocation))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)saveValetLocationObjectIDLocally:(NSString *)valetLocationObjectID;

// order
- (void)fetchCurrentDropOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)fetchCurrentReturnOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock;

// client
- (void)fetchClientObjectWithObjectID:(NSString *)clientObjectID success:(void (^)(ClientObject *clientObject))successBlock fail:(void (^)(NSError *error))failBlock;

@end
