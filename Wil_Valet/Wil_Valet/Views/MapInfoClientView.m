//
//  MapInfoClientView.m
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MapInfoClientView.h"

@interface MapInfoClientView ()

@property (strong, nonatomic) NSString *valetMobilePhoneNumber;

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *callButton;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation MapInfoClientView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)setCLientInfo:(ClientObject *)clientObject address:(NSString *)address {
    
}

- (void)showInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

- (void)hideInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0.0f, 0.0f - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
