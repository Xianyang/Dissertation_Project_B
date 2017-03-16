//
//  MapInfoClientView.m
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MapInfoClientView.h"

@interface MapInfoClientView ()

@property (strong, nonatomic) NSString *clientMobilePhoneNumber;

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *callButton;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIButton *updateOrderBtn;

@end

@implementation MapInfoClientView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        // add photo
        self.profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 15.0f, 70.0f, 70.0f)];
        self.profileImageView.layer.masksToBounds = YES;
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2;
        
        // add name label
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.profileImageView.frame.origin.x + self.profileImageView.frame.size.width + 10, self.profileImageView.frame.origin.y,
                                                                   self.frame.size.width - self.profileImageView.frame.origin.x - self.profileImageView.frame.size.width - 10, 20)];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.font = [UIFont systemFontOfSize:16];
        
        // add address label
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 5,
                                                                      self.nameLabel.frame.size.width, 20)];
        self.addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.addressLabel.textAlignment = NSTextAlignmentLeft;
        self.addressLabel.textColor = [UIColor colorWithRed:155.0f / 255.0f green:155.0f / 255.0f blue:155.0f / 255.0f alpha:1.0f];
        self.addressLabel.font = [UIFont systemFontOfSize:15];
        self.addressLabel.numberOfLines = 0;
        
        // add the call button
        self.callButton = [[UIButton alloc] initWithFrame:CGRectMake(self.addressLabel.frame.origin.x, self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height + 5,
                                                                     30, 20)];
        [self.callButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.callButton setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.callButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.callButton addTarget:self action:@selector(callBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        // add a line
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(self.callButton.frame.origin.x + self.callButton.frame.size.width + 20, self.callButton.frame.origin.y + 2,
                                                                 1, self.callButton.frame.size.height - 4)];
        self.lineView.backgroundColor = [UIColor lightGrayColor];
        
        // add the time label
        self.updateOrderBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.lineView.frame.origin.x + self.lineView.frame.size.width + 20, self.callButton.frame.origin.y,
                                                                   DEVICE_WIDTH - self.lineView.frame.origin.x - self.lineView.frame.size.width - 20., 20)];
        [self.updateOrderBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.updateOrderBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.updateOrderBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.updateOrderBtn addTarget:self action:@selector(updateOrderBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.addressLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.callButton];
        [self addSubview:self.lineView];
        [self addSubview:self.updateOrderBtn];
    }
    
    return self;
}

- (void)setCLientInfo:(ClientObject *)clientObject address:(NSString *)address orderStatus:(UserOrderStatus)orderStatus{
    self.clientMobilePhoneNumber = [clientObject objectForKey:@"mobilePhoneNumber"];
    
    self.profileImageView.image = [UIImage imageNamed:@"client_profile_default"];
    self.nameLabel.text = [NSString stringWithFormat:@"Client: %@ %@", clientObject.last_name, clientObject.first_name];
    
    self.addressLabel.text = [NSString stringWithFormat:@"Meet at %@", address];
    CGRect currentFrame = self.addressLabel.frame;
    CGSize max = CGSizeMake(self.addressLabel.frame.size.width, 40);
    CGSize expected = [self.addressLabel.text sizeWithFont:self.addressLabel.font constrainedToSize:max lineBreakMode:self.addressLabel.lineBreakMode];
    currentFrame.size.height = expected.height;
    self.addressLabel.frame = currentFrame;
    
    [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
    [self.updateOrderBtn setTitle:[self updateOrderText:orderStatus] forState:UIControlStateNormal];
    
    // change frame
    self.callButton.frame = CGRectMake(self.addressLabel.frame.origin.x, self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height + 5,
                                       30, 20);
    self.lineView.frame = CGRectMake(self.callButton.frame.origin.x + self.callButton.frame.size.width + 20, self.callButton.frame.origin.y + 2,
                                     1, self.callButton.frame.size.height - 4);
    self.updateOrderBtn.frame = CGRectMake(self.lineView.frame.origin.x + self.lineView.frame.size.width + 20, self.callButton.frame.origin.y,
                                      self.updateOrderBtn.frame.size.width, self.updateOrderBtn.frame.size.height);
}

- (void)callBtnClicked {
    [self.delegate callClientWithNumber:self.clientMobilePhoneNumber];
}

- (void)updateOrderBtnClicked {
    [self.delegate tryUpdateOrderStatus];
}

- (NSString *)updateOrderText:(UserOrderStatus)orderStatus {
    if (orderStatus == kUserOrderStatusUserDroppingOff) {
        return @"Got the Vehicle";
    } else if (orderStatus == kUserOrderStatusParking) {
        return @"Park finished";
    } else if (orderStatus == kUserOrderStatusRequestingBack) {
        return @"Got the Vehicle";
    } else if (orderStatus == kUserOrderStatusReturningBack) {
        return @"Return finished";
    } else {
        return @"error";
    }
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
