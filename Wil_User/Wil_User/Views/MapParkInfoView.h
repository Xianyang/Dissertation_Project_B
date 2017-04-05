//
//  MapParkInfoView.h
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderObject.h"

@protocol MapParkInfoViewDelegate

- (void)showLocationOfVehicle;
- (void)showInfoOfVehicle;
- (void)showAdditionSerivceView;

@end

@interface MapParkInfoView : UIView

- (id)initWithFrame:(CGRect)frame;

- (void)setOrderObject:(OrderObject *)order;

- (void)showWithOrder:(OrderObject *)order;
- (void)hide;

@property (assign, nonatomic) id <MapParkInfoViewDelegate> delegate;

@end
