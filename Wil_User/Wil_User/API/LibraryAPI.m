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

@interface LibraryAPI()
@property (strong, nonatomic) PolygonClient *polygonClient;
@property (strong, nonatomic) ValetLocationClient *valetLocationClient;

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
    }
    
    return self;
}

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

// valets' locations

- (void)fetchValetsLocationsSuccessful:(void (^)(NSArray *array))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.valetLocationClient fetchValetsLocationsSuccessful:^(NSArray *array) {
        successBlock(array);
    }
                                                        fail:^(NSError *error) {
                                                            failBlock(error);
                                                        }];
}

- (NSArray *)valetLocations {
    return [self.valetLocationClient valetLocations];
}

- (ValetLocation *)nearestValetLocation:(CLLocationCoordinate2D)coordinate {
    return [self.valetLocationClient nearestValetLocation:coordinate];
}

// limit for user's registration
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

@end
