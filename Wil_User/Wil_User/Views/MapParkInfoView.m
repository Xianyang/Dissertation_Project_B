//
//  MapParkInfoView.m
//  Wil_User
//
//  Created by xianyang on 03/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MapParkInfoView.h"

@interface MapParkInfoView ()

@property (strong, nonatomic) OrderObject *order;



@end

@implementation MapParkInfoView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)show {
    self.frame = CGRectMake(self.frame.origin.x, 70, self.frame.size.width, self.frame.size.height);
}

- (void)hide {
    self.frame = CGRectMake(self.frame.origin.x, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setOrderObject:(OrderObject *)order {
    self.order = order;
}

@end
