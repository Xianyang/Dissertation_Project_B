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

// Location
- (NSString *)valetLocationObjectID;
- (void)saveValetLocationObjectID:(NSString *)objectID;

@end
