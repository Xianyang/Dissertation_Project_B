//
//  LibraryAPI.m
//  Wil_User
//
//  Created by xianyang on 19/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "LibraryAPI.h"

@interface LibraryAPI()

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
        
    }
    
    return self;
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
