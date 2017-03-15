//
//  LibraryAPI.m
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "LibraryAPI.h"
#import "PolygonClient.h"
#import "ClientLocationClient.h"
#import "ValetLocationClient.h"
#import "OrderClient.h"

@interface LibraryAPI()
@property (strong, nonatomic) PolygonClient *polygonClient;
@property (strong, nonatomic) ClientLocationClient *clientLocationClient;
@property (strong, nonatomic) ValetLocationClient *valetLocationClient;
@property (strong, nonatomic) OrderClient *orderClient;

@end

@implementation LibraryAPI

+ (LibraryAPI *)sharedInstance
{
    // 1
    static LibraryAPI *_sharedInstance = nil;
    
    // 2
    static dispatch_once_t oncePredicate;
    
    // 3
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

- (id)init
{
    if (self = [super init])
    {
        self.polygonClient = [[PolygonClient alloc] init];
        self.clientLocationClient = [[ClientLocationClient alloc] init];
        self.valetLocationClient = [[ValetLocationClient alloc] init];
        self.orderClient = [[OrderClient alloc] init];
    }
    
    return self;
}

#pragma mark - Polygon

- (NSArray *)polygons {
    return [self.polygonClient polygons];
}

- (GMSPolygon *)polygonForHKIsland {
    return [self.polygonClient polygonForHKIsland];
}

- (GMSPolygon *)polygonForKowloon {
    return [self.polygonClient polygonForKowloon];
}

- (CLLocationCoordinate2D)serviceLocation {
    return [self.polygonClient serviceLocation];
}

#pragma mark - Client's location

- (void)uploadClientLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.clientLocationClient uploadClientLocation:geoPoint
                                         successful:^(ClientLocation *clientLocation) {
                                             successBlock(clientLocation);
                                         }
                                               fail:^(NSError *error) {
                                                   failBlock(error);
                                               }];
}

- (void)saveClientLocationObjectIDLocally:(NSString *)objectID {
    [self.clientLocationClient saveClientLocationObjectIDLocally:objectID];
}

#pragma mark - Valets' locations

- (NSMutableArray *)onlineValetLocations {
    return [self.valetLocationClient onlineValetLocations];
}

- (NSMutableArray *)availableValetLocations {
    return [self.valetLocationClient availableValetLocations];
}

- (NSMutableArray *)busyValetLocations {
    return [self.valetLocationClient busyValetLocations];
}

- (ValetLocation *)dropValetLocation {
    return [self.valetLocationClient dropValetLocation];
}

- (ValetLocation *)returnValetLocation {
    return [self.valetLocationClient returnValetLocation];
}

- (void)fetchValetsLocationsWithStatus:(UserOrderStatus)userOrderStatus
                           orderObject:(OrderObject *)orderObject
                          valetMarkers:(NSArray *)valetMarkers
                               success:(void (^)(NSArray *array))successBlock
                                  fail:(void (^)(NSError *error))failBlock {
    [self.valetLocationClient fetchValetsLocationsWithStatus:userOrderStatus
                                                 orderObject:orderObject
                                                valetMarkers:valetMarkers
                                                     success:^(NSArray *array) {
                                                         successBlock(array);
                                                     }
                                                        fail:^(NSError *error) {
                                                            failBlock(error);
                                                        }];
}

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate {
    return [self.valetLocationClient nearestValetLocation:coordinate];
}

#pragma mark - Orders

- (void)createAnOrderWithValetObjectID:(NSString *)valetObjectID
                 valetLocationObjectID:(NSString *)valetLocationObjectID
                           parkAddress:(NSString *)parkAddress
                          parkLocation:(AVGeoPoint *)parkLocation
                               success:(void (^)(OrderObject *orderObject))successBlock
                                  fail:(void (^)(NSError *error))failBlock {
    [self.orderClient createAnOrderWithValetObjectID:valetObjectID
                               valetLocationObjectID:valetLocationObjectID
                                         parkAddress:parkAddress
                                        parkLocation:parkLocation
                                             success:^(OrderObject *orderObject) {
                                                 successBlock(orderObject);
                                             }
                                                fail:^(NSError *error) {
                                                    failBlock(error);
                                                }];
}

- (void)cancelAnOrderWithOrderObject:(OrderObject *)orderObject
                             success:(void (^)(OrderObject *orderObject))successBlock
                                fail:(void (^)(NSError *error))failBlock {
    [self.orderClient cancelAnOrderWithOrderObject:orderObject
                                           success:^(OrderObject *orderObject) {
                                               successBlock(orderObject);
                                           }
                                              fail:^(NSError *error) {
                                                  failBlock(error);
                                              }];
}

- (void)checkIfUserHasUnfinishedOrder:(void (^)(OrderObject *orderObject))hasOrderBlock noOrder:(void(^)())noOrderBlock fail:(void (^)())failBlock {
    [self.orderClient checkIfUserHasUnfinishedOrder:^(OrderObject *orderObject) {
        hasOrderBlock(orderObject);
    }
                                            noOrder:^{
                                                noOrderBlock();
                                            }
                                               fail:^{
                                                   failBlock();
                                               }];
}

#pragma mark - limit for user's registration

- (NSInteger)maxLengthForPhoneNumber {
    return 11;
}

- (NSInteger)minLengthForPhoneNumber {
    return 8;
}

- (NSInteger)maxLengthForVerificationCode {
    return 6;
}

- (NSInteger)maxLengthForPassword {
    return 30;
}

- (NSInteger)minLengthForPassword {
    return 6;
}

- (NSString *)phonePrefix {
    return @"+852";
}

#pragma mark - color
- (UIColor *)themeBlueColor {
    return [UIColor colorWithRed:65.0f / 255.0f green:148.0f / 255.0f blue:229.0f / 255.0f alpha:1.0f];
}

- (UIColor *)themeLightBlueColor {
    return [UIColor colorWithRed:65.0f / 255.0f green:148.0f / 255.0f blue:229.0f / 255.0f alpha:0.2f];
}

@end
