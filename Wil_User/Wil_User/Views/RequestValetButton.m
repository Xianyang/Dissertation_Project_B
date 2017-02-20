//
//  RequestValetButton.m
//  Wil_User
//
//  Created by xianyang on 20/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "RequestValetButton.h"

@implementation RequestValetButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self setTitle:@"Park Here" forState:UIControlStateNormal];
        [self setBackgroundColor:[UIColor colorWithRed:76.0f / 255.0f green:124.0f / 255.0f blue:194.0f / 255.0f alpha:1.0f]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return self;
}

- (void)setLocation:(NSString *)location {
    [self setTitle:[NSString stringWithFormat:@"Park at %@", location] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
