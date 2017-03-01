//
//  LibraryAPI.m
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "LibraryAPI.h"
#import "PolygonClient.h"

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

@end
