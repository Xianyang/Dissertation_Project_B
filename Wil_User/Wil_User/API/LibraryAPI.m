//
//  LibraryAPI.m
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "LibraryAPI.h"
#import "PolygonClient.h"
#import "ValetLocation.h"

@interface LibraryAPI()
@property (strong, nonatomic) PolygonClient *polygonClient;
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

- (void)getValetsLocationsSuccessful:(void (^)(NSArray *array))successBlock fail:(void (^)(NSError *error))failBlock {
    NSMutableArray *locations = [NSMutableArray array];
    
    AVQuery *query = [AVQuery queryWithClassName:[ValetLocation parseClassName]];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (objects && objects.count > 0 && !error) {
            // create ValetLocation object
            for (AVObject *object in objects) {
                NSInteger timerinterval = [[NSDate date] timeIntervalSinceDate:object.updatedAt];
                NSLog(@"time interval %d", timerinterval);
                
                if ([[NSDate date] timeIntervalSinceDate:object.updatedAt] <= 30) {
                    ValetLocation *valetLocation = [[ValetLocation alloc] initWithAVObject:object];
                    [locations addObject:valetLocation];
                }
            }
            
            successBlock(locations);
        } else {
            failBlock(error);
        }
    }];
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
