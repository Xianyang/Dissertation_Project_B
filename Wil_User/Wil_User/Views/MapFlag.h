//
//  MapFlag.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapFlagDelegate

- (void)flagBtnClicked;

@end

@interface MapFlag : UIView

@property (assign, nonatomic) id <MapFlagDelegate> delegate;

- (void)showWil;
- (void)showGoToServiceArea;
- (void)hideInMapView:(GMSMapView *)mapView;

- (NSString *)text;

@end
