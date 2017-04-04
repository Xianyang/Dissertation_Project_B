//
//  MapParkInfoView.m
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define ORIGIN_Y_WHEN_SHOW     70

#import "MapParkInfoView.h"

@interface MapParkInfoView () {
    BOOL _isShow;
    CGRect _originRect;
}

@property (strong, nonatomic) OrderObject *order;

@property (strong, nonatomic) UILabel *parkLabel;
@property (strong, nonatomic) UIButton *checkLocationBtn;
@property (strong, nonatomic) UIButton *checkImageBtn;
@property (strong, nonatomic) UIButton *additionalServiceBtn;

@end

@implementation MapParkInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _originRect = frame;
        _isShow = NO;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        self.backgroundColor = [UIColor whiteColor];
        
        // add a label
        self.parkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width, 20)];
        self.parkLabel.font = [UIFont systemFontOfSize:16.0f];
        self.parkLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.parkLabel.numberOfLines = 0;
        
        // add three buttons
        self.checkLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.parkLabel.frame.origin.y + self.parkLabel.frame.size.height + 15, 100, 20)];
        [self.checkLocationBtn setTitle:@"check location" forState:UIControlStateNormal];
        [self.checkLocationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.checkLocationBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.checkLocationBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.checkLocationBtn addTarget:self action:@selector(checkLocationBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.checkLocationBtn setBackgroundColor:[UIColor yellowColor]];
        
        self.checkImageBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.checkLocationBtn.frame.origin.x + self.checkLocationBtn.frame.size.width + 20, self.checkLocationBtn.frame.origin.y, 90, 20)];
        [self.checkImageBtn setTitle:@"check image" forState:UIControlStateNormal];
        [self.checkImageBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.checkImageBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.checkImageBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.checkImageBtn addTarget:self action:@selector(checkImageBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.checkImageBtn setBackgroundColor:[UIColor greenColor]];
        
        self.additionalServiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.checkImageBtn.frame.origin.x + self.checkImageBtn.frame.size.width + 20, self.checkImageBtn.frame.origin.y, 120, 20)];
        [self.additionalServiceBtn setTitle:@"additional serivce" forState:UIControlStateNormal];
        [self.additionalServiceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.additionalServiceBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.additionalServiceBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.additionalServiceBtn addTarget:self action:@selector(additionalServiceBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.additionalServiceBtn setBackgroundColor:[UIColor yellowColor]];
        
        self.checkLocationBtn.hidden = YES;
        self.checkImageBtn.hidden = YES;
        self.additionalServiceBtn.hidden = YES;
        

        [self addSubview:self.parkLabel];
        [self addSubview:self.checkLocationBtn];
        [self addSubview:self.checkImageBtn];
        [self addSubview:self.additionalServiceBtn];
    }
    
    return self;
}

- (void)showWithOrder:(OrderObject *)order {
    if (_isShow) {
        return;
    }
    
    _isShow = YES;
    
    self.frame = CGRectMake(self.frame.origin.x, ORIGIN_Y_WHEN_SHOW, self.frame.size.width, self.frame.size.height);
    
    // update the park address
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self animated:YES];
    [[LibraryAPI sharedInstance] reverseGeocodeCoordinate:[order.parked_location coordinateWithGeoPoint:order.parked_location]
                                                  success:^(GMSReverseGeocodeResponse *response) {
                                                      self.parkLabel.text = [NSString stringWithFormat:@"Your vehicle is parked at %@, you can request it back anytime", response.results[0].lines[0]];
                                                      
                                                      CGRect currentFrame = self.parkLabel.frame;
                                                      CGSize max = CGSizeMake(self.parkLabel.frame.size.width, 40);
                                                      CGSize expected = [self.parkLabel.text sizeWithFont:self.parkLabel.font constrainedToSize:max lineBreakMode:self.parkLabel.lineBreakMode];
                                                      currentFrame.size.height = expected.height;
                                                      self.parkLabel.frame = currentFrame;
                                                      
                                                      // update buttons' frame
                                                      self.checkLocationBtn.hidden = NO;
                                                      self.checkImageBtn.hidden = NO;
                                                      self.additionalServiceBtn.hidden = NO;
                                                      
                                                      self.checkLocationBtn.frame = CGRectMake(20, self.parkLabel.frame.origin.y + self.parkLabel.frame.size.height + 15, 100, 20);
                                                      self.checkImageBtn.frame = CGRectMake(self.checkLocationBtn.frame.origin.x + self.checkLocationBtn.frame.size.width + 20, self.checkLocationBtn.frame.origin.y, 90, 20);
                                                      self.additionalServiceBtn.frame = CGRectMake(self.checkImageBtn.frame.origin.x + self.checkImageBtn.frame.size.width + 20, self.checkImageBtn.frame.origin.y, 120, 20);
                                                      
                                                      // update self.frame
                                                      CGRect frame = self.frame;
                                                      frame.size.height = self.checkLocationBtn.frame.origin.y + self.checkLocationBtn.frame.size.height + 15;
                                                      self.frame = frame;
                                                      
                                                      [hud hideAnimated:YES];
                                                  }
                                                     fail:^(NSError *error) {
                                                         
                                                     }];
}

- (void)hide {
    _isShow = NO;
    self.frame = _originRect;
}

- (void)setOrderObject:(OrderObject *)order {
    self.order = order;
    
    }

- (void)checkLocationBtnClicked {
    [self.delegate showLocationOfVehicle];
}

- (void)checkImageBtnClicked {
    [self.delegate showImageOfVehicle];
}

- (void)additionalServiceBtnClicked {
    [self.delegate showAdditionSerivceView];
}

@end
