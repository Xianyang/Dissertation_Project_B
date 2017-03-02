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
        [self setBackgroundColor:[[LibraryAPI sharedInstance] themeBlueColor]];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return self;
}

- (void)setLocation:(NSString *)location {
    [self setTitle:[NSString stringWithFormat:@"Drop off at %@", location] forState:UIControlStateNormal];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
