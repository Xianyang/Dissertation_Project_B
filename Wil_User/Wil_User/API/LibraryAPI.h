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
#import "ClientLocation.h"
#import "OrderObject.h"

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
    
    // valet is returning the vehicle
    kUserOrderStatusReturningBack,
    
    // user needs to pay for the service
    kUserOrderStatusPaymentPending,
    
    // the order is finished
    kUserOrderStatusFinished,
    
    // the order is cancel
    kUserOrderStatusCancel
} UserOrderStatus;

+ (LibraryAPI *)sharedInstance;

// polygon
- (NSArray *)polygons;
- (GMSPolygon *)polygonForHKIsland;
- (GMSPolygon *)polygonForKowloon;
- (CLLocationCoordinate2D)serviceLocation;
- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate success:(void(^)(GMSReverseGeocodeResponse *response))successBlock fail:(void (^)(NSError *error))failBlock;

// clien's location
- (void)uploadClientLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)saveClientLocationObjectIDLocally:(NSString *)objectID;
- (void)resetClientLocationObjectID;
- (void)getRouteWithMyLocation:(CLLocation *)myLocation destinationLocation:(CLLocation *)destinationLocation success:(void (^)(GMSPolyline *route))successBlock fail:(void (^)(NSError *error))failBlock;

// valets' locations
- (NSMutableArray *)onlineValetLocations;
- (NSMutableArray *)availableValetLocations;
- (NSMutableArray *)busyValetLocations;
- (ValetLocation *)dropValetLocation;
- (ValetLocation *)returnValetLocation;

- (void)fetchValetsLocationsWithStatus:(UserOrderStatus)userOrderStatus
                           orderObject:(OrderObject *)orderObject
                          valetMarkers:(NSArray *)valetMarkers
                               success:(void (^)(NSArray *array))successBlock
                                  fail:(void (^)(NSError *error))failBlock;

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate;
- (NSString *)timeFromValetLocationToMeetLocation:(NSString *)valetObjectID meetLocation:(CLLocation *)meetLocation;

// order
- (void)createAnOrderWithValetObjectID:(NSString *)valetObjectID
                 valetLocationObjectID:(NSString *)valetLocationObjectID
                           parkAddress:(NSString *)parkAddress
                          parkLocation:(AVGeoPoint *)parkLocation
                               success:(void (^)(OrderObject *orderObject))successBlock
                                  fail:(void (^)(NSError *error))failBlock;

- (void)fetchOrderStatusWithObjectID:(NSString *)orderObjectID success:(void (^)(OrderObject *orderObject))successBlock fail:(void (^)(NSError *error))failBlock;

- (void)cancelAnOrderWithOrderObject:(OrderObject *)orderObject
                             success:(void (^)(OrderObject *orderObject))successBlock
                                fail:(void (^)(NSError *error))failBlock;

- (void)updateAnOrderWithOrderObject:(OrderObject *)orderObject
                            toStatus:(UserOrderStatus)orderStatus
                             success:(void (^)(OrderObject *orderobject))successBlock
                                fail:(void (^)(NSError *error))failBlock;

- (void)requestingVehicleBackWithOrderObject:(OrderObject *)orderObject
                               valetObjectID:(NSString *)valetObjectID
                       valetLocationObjectID:(NSString *)valetLocationObjectID
                               returnAddress:(NSString *)returnAddress
                              returnLocation:(AVGeoPoint *)returnLocation
                                  returnTime:(NSDate *)returnTime
                                     success:(void (^)(OrderObject *orderObject))successBlock
                                        fail:(void (^)(NSError *error))failBlock;

- (void)checkIfUserHasUnfinishedOrder:(void (^)(OrderObject *orderObject))hasOrderBlock noOrder:(void(^)())noOrderBlock fail:(void (^)())failBlock;

// file
- (void)uploadFile:(AVFile *)file success:(void (^)(NSString *fileURL))successBlock fail:(void (^)(NSError *error))failBlock;
- (void)getPhotoWithURL:(NSString *)imageURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;
//- (void)getAppUserProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;
//- (void)getClientProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;
//- (void)getValetProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock;

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

@end
