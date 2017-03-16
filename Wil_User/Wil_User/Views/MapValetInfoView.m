//
//  MapValetInfoView.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MapValetInfoView.h"
#import "ValetObject.h"

@interface MapValetInfoView ()

@property (strong, nonatomic) NSString *valetMobilePhoneNumber;

@property (strong, nonatomic) UIImageView *profileImageView;
@property (strong, nonatomic) UILabel *subInfoLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UIButton *callButton;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation MapValetInfoView

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
        self.subInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nameLabel.frame.origin.x, self.nameLabel.frame.origin.y + self.nameLabel.frame.size.height + 5,
                                                                      self.nameLabel.frame.size.width, 20)];
        self.subInfoLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.subInfoLabel.textAlignment = NSTextAlignmentLeft;
        self.subInfoLabel.textColor = [UIColor colorWithRed:155.0f / 255.0f green:155.0f / 255.0f blue:155.0f / 255.0f alpha:1.0f];
        self.subInfoLabel.font = [UIFont systemFontOfSize:15];
        self.subInfoLabel.numberOfLines = 0;
        
        // add the call button
        self.callButton = [[UIButton alloc] initWithFrame:CGRectMake(self.subInfoLabel.frame.origin.x, self.subInfoLabel.frame.origin.y + self.subInfoLabel.frame.size.height + 5,
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
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineView.frame.origin.x + self.lineView.frame.size.width + 20, self.callButton.frame.origin.y,
                                                                   100, 20)];
        
        self.timeLabel.textColor = [UIColor colorWithRed:124.0f / 255.0f green:160.0f / 255.0f blue:98.0f / 255.0f alpha:1.0f];
        self.timeLabel.font = [UIFont systemFontOfSize:15];
        
        
        [self addSubview:self.profileImageView];
        [self addSubview:self.subInfoLabel];
        [self addSubview:self.nameLabel];
        [self addSubview:self.callButton];
        [self addSubview:self.lineView];
        [self addSubview:self.timeLabel];
    }
    
    return self;
}

- (void)showInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

- (void)hideInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0.0f, 0.0f - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setValetInfo:(NSString *)valetObjectID address:(NSString *)address orderStatus:(UserOrderStatus)orderStatus{
    ValetObject *valetObject = [ValetObject objectWithObjectId:valetObjectID];
    [valetObject fetchInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if (object && !error) {
            self.valetMobilePhoneNumber = [valetObject objectForKey:@"mobilePhoneNumber"];
            self.profileImageView.image = [UIImage imageNamed:@"valet_profile_default"];
            
            if (orderStatus == kUserOrderStatusUserDroppingOff) {
                self.nameLabel.text = [NSString stringWithFormat:@"Meet Your Valet: %@ %@", valetObject.last_name, valetObject.first_name];
                self.subInfoLabel.text = [NSString stringWithFormat:@"Meet him at %@", address];
                [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
                self.timeLabel.hidden = NO;
                self.timeLabel.text = @"5 minutes";
            } else if (orderStatus == kUserOrderStatusParking) {
                self.nameLabel.text = [NSString stringWithFormat:@"Your Valet: %@ %@", valetObject.last_name, valetObject.first_name];
                self.subInfoLabel.text = @"He is parking your vehicle";
                [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
                self.timeLabel.hidden = NO;
                self.timeLabel.text = @"Enjoy!";
            } else if (orderStatus == kUserOrderStatusRequestingBack) {
                self.nameLabel.text = [NSString stringWithFormat:@"Meet Your Valet: %@ %@", valetObject.last_name, valetObject.first_name];
                self.subInfoLabel.text = [NSString stringWithFormat:@"Return vehicle at %@", address];
                [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
                self.timeLabel.hidden = NO;
                // TODO set time
                self.timeLabel.text = @"5 minutes";
            } else if (orderStatus == kUserOrderStatusReturningBack) {
                self.nameLabel.text = [NSString stringWithFormat:@"Meet Your Valet: %@ %@", valetObject.last_name, valetObject.first_name];
                self.subInfoLabel.text = [NSString stringWithFormat:@"Returning vehicle at %@", address];
                [self.callButton setTitle:@"Call" forState:UIControlStateNormal];
                self.timeLabel.hidden = NO;
                // TODO set time
                self.timeLabel.text = @"5 minutes";
            }
            
            CGRect currentFrame = self.subInfoLabel.frame;
            CGSize max = CGSizeMake(self.subInfoLabel.frame.size.width, 40);
            CGSize expected = [self.subInfoLabel.text sizeWithFont:self.subInfoLabel.font constrainedToSize:max lineBreakMode:self.subInfoLabel.lineBreakMode];
            currentFrame.size.height = expected.height;
            self.subInfoLabel.frame = currentFrame;
            
            // change frame
            self.callButton.frame = CGRectMake(self.subInfoLabel.frame.origin.x, self.subInfoLabel.frame.origin.y + self.subInfoLabel.frame.size.height + 5,
                                               30, 20);
            self.lineView.frame = CGRectMake(self.callButton.frame.origin.x + self.callButton.frame.size.width + 20, self.callButton.frame.origin.y + 2,
                                             1, self.callButton.frame.size.height - 4);
            self.timeLabel.frame = CGRectMake(self.lineView.frame.origin.x + self.lineView.frame.size.width + 20, self.callButton.frame.origin.y,
                                              100, 20);
        } else {
            
        }
    }];
}

- (void)callBtnClicked {
    [self.delegate callValetWithNumber:self.valetMobilePhoneNumber];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
