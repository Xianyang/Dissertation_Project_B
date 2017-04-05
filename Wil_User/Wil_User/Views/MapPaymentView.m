//
//  MapPaymentView.m
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define CHARGE_PER_HOUR  50

#import "MapPaymentView.h"

@interface MapPaymentView ()

@property (strong, nonatomic) OrderObject *order;
@property (strong, nonatomic) UIImageView *applePayImageView;
@property (strong, nonatomic) UIButton *applePayButton;
@property (strong, nonatomic) UILabel *billLabel;
@property (strong, nonatomic) NSDecimalNumber *amount;

@end

@implementation MapPaymentView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.billLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 12, self.frame.size.width, self.frame.size.height - 24)];
        self.billLabel.textColor = [UIColor blackColor];
        
        self.applePayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 170, 12, 140, 40)];
        self.applePayImageView.image = [UIImage imageNamed:@"apple_pay"];
        
        self.applePayButton = [[UIButton alloc] initWithFrame:self.applePayImageView.frame];
        [self.applePayButton addTarget:self action:@selector(applePayButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        
        
        [self addSubview:self.billLabel];
        [self addSubview:self.applePayImageView];
        [self addSubview:self.applePayButton];
    }
    
    return self;
}

- (void)showInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(self.frame.origin.x, mapView.frame.size.height - self.frame.size.height,
                            self.frame.size.width, self.frame.size.height);
}

- (void)hideInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(self.frame.origin.x, mapView.frame.size.height,
                            self.frame.size.width, self.frame.size.height);
}

- (void)setOrderObject:(OrderObject *)order {
    self.order = order;
    NSTimeInterval timeInterval = [order.return_at timeIntervalSinceDate:order.drop_off_at];
    double amountValue = timeInterval * CHARGE_PER_HOUR / 3600;
    self.amount = [NSDecimalNumber decimalNumberWithDecimal:[[NSNumber numberWithDouble:amountValue] decimalValue]];
    
    self.billLabel.text = [NSString stringWithFormat:@"Pay your bill:$%.2f", amountValue];
}

- (NSNumber *)paymentAmount {
    return self.amount;
}

- (void)applePayButtonClicked {
    [self.delegate applePayBtnClicked:self.amount];
}

@end
