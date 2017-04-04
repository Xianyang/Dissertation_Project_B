//
//  MapParkInfoView.m
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define ORIGIN_Y_WHEN_SHOW     70

#import "MapParkInfoView.h"

@interface MapParkInfoView () {
    CGRect _originRect;
}

@property (strong, nonatomic) OrderObject *order;



@end

@implementation MapParkInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _originRect = frame;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)show {
    self.frame = CGRectMake(self.frame.origin.x, ORIGIN_Y_WHEN_SHOW, self.frame.size.width, self.frame.size.height);
}

- (void)hide {
    self.frame = _originRect;
}

- (void)setOrderObject:(OrderObject *)order {
    self.order = order;
}

@end
