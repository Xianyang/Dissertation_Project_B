//
//  UIButton+Status.m
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "UIButton+Status.h"

@implementation UIButton (Status)

- (void)setEnableStatus {
    [self setEnabled:YES];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setDisableStatus {
    [self setEnabled:NO];
    [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

@end
