//
//  MapInfoClientView.h
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ClientObject.h"

@protocol MapClientInfoViewDelegate

- (void)callClientWithNumber:(NSString *)mobilePhoneNumber;
- (void)tryUpdateOrderStatus;

@end

@interface MapInfoClientView : UIView

@property (strong, nonatomic) NSString *clientObjectID;
@property (assign, nonatomic) id <MapClientInfoViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)showInMapView:(GMSMapView *)mapView;
- (void)hideInMapView:(GMSMapView *)mapView;

- (void)setCLientInfo:(ClientObject *)clientObject address:(NSString *)address orderStatus:(UserOrderStatus)orderStatus;

@end
