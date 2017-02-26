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

@interface LibraryAPI : NSObject

+ (LibraryAPI *)sharedInstance;

- (NSArray *)polygons;
- (GMSPolygon *)polygonForHKIsland;
- (GMSPolygon *)polygonForKowloon;

- (NSInteger)maxLengthForPhoneNumber;
- (NSInteger)minLengthForPhoneNumber;
- (NSInteger)maxLengthForVerificationCode;
- (NSInteger)maxLengthForPassword;

@end
