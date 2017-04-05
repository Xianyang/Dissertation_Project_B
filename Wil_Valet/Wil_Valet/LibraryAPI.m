//
//  LibraryAPI.m
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "LibraryAPI.h"
#import "PolygonClient.h"
#import "ValetLocationClient.h"
#import "ClientLocationClient.h"
#import "OrderClient.h"
#import "ClientClient.h"
#import "FileClient.h"

static NSString * const LocationObjectName = @"valet_location_object_id";

@interface LibraryAPI()

@property (strong, nonatomic) PolygonClient *polygonClient;
@property (strong, nonatomic) ValetLocationClient *valetLocationClient;
@property (strong, nonatomic) ClientLocationClient *clientLocationClient;
@property (strong, nonatomic) OrderClient *orderClient;
@property (strong, nonatomic) ClientClient *clientClient;
@property (strong, nonatomic) FileClient *fileClient;
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
        self.valetLocationClient = [[ValetLocationClient alloc] init];
        self.clientLocationClient = [[ClientLocationClient alloc] init];
        self.orderClient = [[OrderClient alloc] init];
        self.clientClient = [[ClientClient alloc] init];
        self.fileClient = [[FileClient alloc] init];
    }
    
    return self;
}

#pragma mark - Orders

- (void)fetchCurrentDropOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.orderClient fetchCurrentDropOrder:^(NSArray *orders) {
        successBlock(orders);
    }
                                   fail:^(NSError *error) {
                                       failBlock(error);
                                   }];
}

- (void)fetchCurrentReturnOrder:(void (^)(NSArray *orders))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.orderClient fetchCurrentReturnOrder:^(NSArray *orders) {
        successBlock(orders);
    }
                                         fail:^(NSError *error) {
                                             failBlock(error);
                                         }];
}

#pragma mark - CLient

- (void)fetchClientObjectWithObjectID:(NSString *)clientObjectID success:(void (^)(ClientObject *clientObject))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.clientClient fetchClientObjectWithObjectID:clientObjectID
                                             success:^(ClientObject *clientObject) {
                                                 successBlock(clientObject);
                                             }
                                                fail:^(NSError *error) {
                                                    failBlock(error);
                                                }];
}

- (ClientObject *)clientObjectWithObjectID:(NSString *)clientObjectID {
    return [self.clientClient clientObjectWithObjectID:clientObjectID];
}

#pragma mark - File

- (void)uploadFile:(AVFile *)file success:(void (^)(NSString *fileURL))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.fileClient uploadFile:file
                        success:^(NSString *fileURL) {
                            successBlock(fileURL);
                        }
                           fail:^(NSError *error) {
                               failBlock(error);
                           }];
}

- (void)getPhotoWithURL:(NSString *)imageURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.fileClient getPhotoWithURL:imageURL
                             success:^(UIImage *image) {
                                 successBlock(image);
                             }
                                fail:^(NSError *error) {
                                    failBlock(error);
                                }];
}

//- (void)getAppUserProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
//    [self.fileClient getAppUserProfilePhotoWithURL:fileURL
//                                           success:^(UIImage *image) {
//                                               successBlock(image);
//                                           }
//                                              fail:^(NSError *error) {
//                                                  failBlock(error);
//                                              }];
//}
//
//- (void)getClientProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
//    [self.fileClient getClientProfilePhotoWithURL:fileURL
//                                          success:^(UIImage *image) {
//                                              successBlock(image);
//                                          }
//                                             fail:^(NSError *error) {
//                                                 failBlock(error);
//                                             }];
//}
//
//- (void)getValetProfilePhotoWithURL:(NSString *)fileURL success:(void (^)(UIImage *image))successBlock fail:(void (^)(NSError *error))failBlock {
//    
//}

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

// color
- (UIColor *)themeBlueColor {
    return [UIColor colorWithRed:65.0f / 255.0f green:148.0f / 255.0f blue:229.0f / 255.0f alpha:1.0f];
}

- (UIColor *)themeLightBlueColor {
    return [UIColor colorWithRed:65.0f / 255.0f green:148.0f / 255.0f blue:229.0f / 255.0f alpha:0.2f];
}

// Location

- (void)uploadValetLocation:(AVGeoPoint *)geoPoint successful:(void (^)(ValetLocation *valetLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.valetLocationClient uploadValetLocation:geoPoint
                                       successful:^(ValetLocation *valetLocation) {
                                           successBlock(valetLocation);
                                       }
                                             fail:^(NSError *error) {
                                                 failBlock(error);
                                             }];
}

- (void)getRouteWithMyLocation:(CLLocation *)myLocation destinationLocation:(CLLocation *)destinationLocation success:(void (^)(GMSPolyline *route))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.valetLocationClient getRouteWithMyLocation:myLocation
                                 destinationLocation:destinationLocation
                                             success:^(GMSPolyline *route) {
                                                 successBlock(route);
                                             }
                                                fail:^(NSError *error) {
                                                    failBlock(error);
                                                }];
}

- (void)saveValetLocationObjectIDLocally:(NSString *)valetLocationObjectID {
    [self.valetLocationClient saveValetLocationObjectIDLocally:valetLocationObjectID];
}

- (void)fetchClientLocationWithClientObjectID:(NSString *)clientObjectID success:(void (^)(ClientLocation *clientLocation))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.clientLocationClient fetchClientLocationWithClientObjectID:clientObjectID
                                                             success:^(ClientLocation *clientLocation) {
                                                                 successBlock(clientLocation);
                                                             }
                                                                fail:^(NSError *error) {
                                                                    failBlock(error);
                                                                }];
}

- (void)updateValetServingStatus:(BOOL)isServing {
    [self.valetLocationClient updateValetServingStatus:isServing];
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

@end
