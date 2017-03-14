//
//  MapValetInfoView.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapValetInfoView : UIView

@property (strong, nonatomic) NSString *valetObjectID;

- (void)showInMapView:(GMSMapView *)mapView;

- (void)setValetInfo:(NSString *)valetObjectID;

@end
