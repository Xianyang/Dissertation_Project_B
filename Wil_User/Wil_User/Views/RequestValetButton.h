//
//  RequestValetButton.h
//  Wil_User
//
//  Created by xianyang on 20/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestValetButton : UIButton

- (id)initWithFrame:(CGRect)frame;
- (void)setLocation:(NSString *)location orderStatus:(UserOrderStatus)orderStatus;
- (void)setStatus:(UserOrderStatus)orderStatus;
- (NSString *)parkAddress;

- (void)showInMapView:(GMSMapView *)mapView;
- (void)hideInMapView:(GMSMapView *)mapView;

@end
