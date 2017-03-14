//
//  MapValetInfoView.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MapValetInfoView.h"
#import "ValetObject.h"

@implementation MapValetInfoView

- (void)showInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(0.0f, 0.0f, self.frame.size.width, self.frame.size.height);
}

- (void)setValetInfo:(NSString *)valetObjectID {
    ValetObject *valetObject = [ValetObject objectWithObjectId:valetObjectID];
    [valetObject fetchInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
        if (object && !error) {
            UILabel *firstNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 100, 30)];
            firstNameLabel.text = valetObject.first_name;
            firstNameLabel.textColor = [UIColor blackColor];
            [self addSubview:firstNameLabel];
        } else {
            
        }
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
