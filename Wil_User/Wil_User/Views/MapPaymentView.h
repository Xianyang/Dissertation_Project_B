//
//  MapPaymentView.h
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderObject.h"

@protocol MapPaymentViewDelegate

- (void)applePayBtnClicked:(NSDecimalNumber *)amount;

@end

@interface MapPaymentView : UIView

@property (assign, nonatomic) id <MapPaymentViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)setOrderObject:(OrderObject *)order;
- (NSNumber *)paymentAmount;

- (void)hideInMapView:(GMSMapView *)mapView;
- (void)showInMapView:(GMSMapView *)mapView;

@end
