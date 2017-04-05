//
//  MapValetInfoView.h
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderObject.h"

@protocol MapValetInfoViewDelegate

- (void)callValetWithNumber:(NSString *)mobilePhoneNumber;

@end

@interface MapValetInfoView : UIView

@property (strong, nonatomic) NSString *valetObjectID;
@property (assign, nonatomic) id <MapValetInfoViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame;

- (void)show;
- (void)hide;

- (void)setOrder:(OrderObject *)orderObject;



@end
