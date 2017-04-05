//
//  MapParkInfoView.m
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define ORIGIN_Y_WHEN_SHOW     70
#define VERTICAL_MARGIN        10

#import "MapParkInfoView.h"

@interface MapParkInfoView () {
    BOOL _isShow;
    CGRect _originRect;
}

@property (strong, nonatomic) OrderObject *order;

@property (strong, nonatomic) UILabel *parkLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UIButton *checkLocationBtn;
@property (strong, nonatomic) UIButton *checkVehicleBtn;
@property (strong, nonatomic) UIButton *additionalServiceBtn;

@property (strong, nonatomic) NSTimer *timer;

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
        self.parkLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width - 40, 20)];
        self.parkLabel.font = [UIFont systemFontOfSize:16.0f];
        self.parkLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.parkLabel.numberOfLines = 0;
        
        // add price label
        self.priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.parkLabel.frame.origin.y + self.parkLabel.frame.size.height + VERTICAL_MARGIN, 100, 20)];
        self.priceLabel.font = [UIFont systemFontOfSize:16.0f];
        self.priceLabel.textColor = [UIColor colorWithRed:124.0f / 255.0f green:160.0f / 255.0f blue:98.0f / 255.0f alpha:1.0f];
        
        // add time label
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 20, self.priceLabel.frame.origin.y, 90, 20)];
        self.timeLabel.font = [UIFont systemFontOfSize:16.0f];
        self.timeLabel.textColor = [UIColor colorWithRed:124.0f / 255.0f green:160.0f / 255.0f blue:98.0f / 255.0f alpha:1.0f];
        
        // add three buttons
        self.checkLocationBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height + VERTICAL_MARGIN, 100, 20)];
        [self.checkLocationBtn setTitle:@"check location" forState:UIControlStateNormal];
        [self.checkLocationBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.checkLocationBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.checkLocationBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.checkLocationBtn addTarget:self action:@selector(checkLocationBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.checkLocationBtn setBackgroundColor:[UIColor yellowColor]];
        
        self.checkVehicleBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.checkLocationBtn.frame.origin.x + self.checkLocationBtn.frame.size.width + 20, self.checkLocationBtn.frame.origin.y, 100, 20)];
        [self.checkVehicleBtn setTitle:@"check vehicle" forState:UIControlStateNormal];
        [self.checkVehicleBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.checkVehicleBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.checkVehicleBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.checkVehicleBtn addTarget:self action:@selector(checkVehicleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.checkVehicleBtn setBackgroundColor:[UIColor greenColor]];
        
        self.additionalServiceBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.checkVehicleBtn.frame.origin.x + self.checkVehicleBtn.frame.size.width + 20, self.checkVehicleBtn.frame.origin.y, 120, 20)];
        [self.additionalServiceBtn setTitle:@"additional serivce" forState:UIControlStateNormal];
        [self.additionalServiceBtn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.additionalServiceBtn setTitleColor:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
        [self.additionalServiceBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [self.additionalServiceBtn addTarget:self action:@selector(additionalServiceBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.additionalServiceBtn setBackgroundColor:[UIColor yellowColor]];
        
        self.checkLocationBtn.hidden = YES;
        self.checkVehicleBtn.hidden = YES;
        self.additionalServiceBtn.hidden = YES;
        

        [self addSubview:self.parkLabel];
        [self addSubview:self.priceLabel];
        [self addSubview:self.timeLabel];
        [self addSubview:self.checkLocationBtn];
        [self addSubview:self.checkVehicleBtn];
        [self addSubview:self.additionalServiceBtn];
    }
    
    return self;
}

- (void)showWithOrder:(OrderObject *)order {
    if (_isShow) {
        return;
    }
    
    self.order = order;
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
                                                      
                                                      // update labels' text
                                                      self.priceLabel.text = @"$50/hr";
                                                      [self.timer setFireDate:[NSDate date]];
                                                      
                                                      // update labels' frame
                                                      self.priceLabel.frame = CGRectMake(20, self.parkLabel.frame.origin.y + self.parkLabel.frame.size.height + VERTICAL_MARGIN, 100, 20);
                                                      self.timeLabel.frame = CGRectMake(self.priceLabel.frame.origin.x + self.priceLabel.frame.size.width + 20, self.priceLabel.frame.origin.y, 90, 20);
                                                      
                                                      // update buttons' frame
                                                      self.checkLocationBtn.hidden = NO;
                                                      self.checkVehicleBtn.hidden = NO;
                                                      self.additionalServiceBtn.hidden = NO;
                                                      
                                                      self.checkLocationBtn.frame = CGRectMake(20, self.priceLabel.frame.origin.y + self.priceLabel.frame.size.height + VERTICAL_MARGIN, 100, 20);
                                                      self.checkVehicleBtn.frame = CGRectMake(self.checkLocationBtn.frame.origin.x + self.checkLocationBtn.frame.size.width + 20, self.checkLocationBtn.frame.origin.y, 100, 20);
                                                      self.additionalServiceBtn.frame = CGRectMake(self.checkVehicleBtn.frame.origin.x + self.checkVehicleBtn.frame.size.width + 20, self.checkVehicleBtn.frame.origin.y, 120, 20);
                                                      
                                                      // update self.frame
                                                      CGRect frame = self.frame;
                                                      frame.size.height = self.checkLocationBtn.frame.origin.y + self.checkLocationBtn.frame.size.height + 15;
                                                      self.frame = frame;
                                                      
                                                      [hud hideAnimated:YES];
                                                  }
                                                     fail:^(NSError *error) {
                                                         
                                                     }];
}

- (void)updateTimeLabel {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.order.drop_off_at];
    self.timeLabel.text = [self stringFromTimeInterval:timeInterval];
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours, (long)minutes, (long)seconds];
}

- (void)hide {
    _isShow = NO;
    self.frame = _originRect;
}

- (void)checkLocationBtnClicked {
    [self.delegate showLocationOfVehicle];
}

- (void)checkVehicleBtnClicked {
    [self.delegate showInfoOfVehicle];
}

- (void)additionalServiceBtnClicked {
    [self.delegate showAdditionSerivceView];
}

- (NSTimer *)timer {
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1
                                                  target:self
                                                selector:@selector(updateTimeLabel)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    return _timer;
}

@end
