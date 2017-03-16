//
//  RequestValetButton.m
//  Wil_User
//
//  Created by xianyang on 20/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "RequestValetButton.h"

@interface RequestValetButton ()

@property (strong, nonatomic) NSString *address;

@end

@implementation RequestValetButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitle:@"Park Here" forState:UIControlStateNormal];
        [self setBackgroundColor:[[LibraryAPI sharedInstance] themeBlueColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return self;
}

- (NSString *)parkAddress {
    if (self.address) {
        return self.address;
    } else {
        return @"";
    }
}

- (void)setLocation:(NSString *)location orderStatus:(UserOrderStatus)orderStatus {
    self.address = location;
    
    if (orderStatus == kUserOrderStatusNone) {
        [self setTitle:[NSString stringWithFormat:@"Drop off at %@", location] forState:UIControlStateNormal];
    } else if (orderStatus == kUserOrderStatusParked) {
        [self setTitle:[NSString stringWithFormat:@"Return vehicle at %@", location] forState:UIControlStateNormal];
    }
}

- (void)showInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0, mapView.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)hideInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0, mapView.frame.size.height, self.frame.size.width, self.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
