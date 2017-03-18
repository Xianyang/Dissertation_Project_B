//
//  MapSearchPlaceView.h
//  Wil_User
//
//  Created by xianyang on 18/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapSearchPlaceViewDelegate

- (void)searchBtnClicked;

@end

@interface MapSearchPlaceView : UIView

- (id)initWithFrame:(CGRect)frame;

@property (assign, nonatomic) id <MapSearchPlaceViewDelegate> delegate;

- (void)setParkAddress:(NSString *)parkAddress;
- (void)show;
- (void)hide;

@end
