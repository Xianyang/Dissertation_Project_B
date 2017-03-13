//
//  MapFlag.m
//  Wil_User
//
//  Created by xianyang on 13/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define FLAG_WIDTH_WIL 70
#define FLAG_WIDTH_GO_TO_SERIVCE_AREA 130
#define FLAG_RECT_HEIGHT 35
#define FLAG_LINE_HEIGHT 35

#import "MapFlag.h"

@interface MapFlag ()

@property (strong, nonatomic) UIView *flagRect;
@property (strong, nonatomic) UIView *flagLine;
@property (strong, nonatomic) UILabel *flagLabel;
@property (strong, nonatomic) UIButton *flagBtn;

@end

@implementation MapFlag

- (id)init {
    if (self = [super init]) {
        self.frame = CGRectMake(142, 100, FLAG_WIDTH_GO_TO_SERIVCE_AREA, FLAG_RECT_HEIGHT + FLAG_LINE_HEIGHT);
        
        self.flagRect = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y, FLAG_WIDTH_GO_TO_SERIVCE_AREA, FLAG_RECT_HEIGHT)];
        self.flagRect.layer.masksToBounds = YES;
        self.flagRect.layer.cornerRadius = 5;
        
        self.flagLine = [[UIView alloc] initWithFrame:CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                                                 self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                                                 2, FLAG_LINE_HEIGHT)];
        
        self.flagLabel = [[UILabel alloc] initWithFrame:self.flagRect.frame];
        self.flagLabel.textColor = [UIColor whiteColor];
        self.flagLabel.textAlignment = NSTextAlignmentCenter;
        
        self.flagBtn = [[UIButton alloc] initWithFrame:self.flagRect.frame];
        
        [self addSubview:self.flagRect];
        [self addSubview:self.flagLine];
        [self addSubview:self.flagLabel];
        [self addSubview:self.flagBtn];
    }
    
    return self;
}

- (void)showWil {
    // 0. change the view
    self.frame = CGRectMake((DEVICE_WIDTH - FLAG_WIDTH_WIL) / 2, (DEVICE_HEIGHT - 64) / 2 - FLAG_RECT_HEIGHT * 2,
                            FLAG_WIDTH_WIL, FLAG_RECT_HEIGHT * 2);
    
    // 1. change the rect
    self.flagRect.frame = CGRectMake(0, 0, self.frame.size.width, FLAG_RECT_HEIGHT);
    self.flagRect.backgroundColor = [UIColor blackColor];
    
    // 2. change the line
    self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                     self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                     2, FLAG_RECT_HEIGHT);
    self.flagLine.backgroundColor = self.flagRect.backgroundColor;
    
    // 3. change the text
    self.flagLabel.frame = self.flagRect.frame;
    self.flagLabel.text = @"WIL";
    self.flagLabel.font = [UIFont systemFontOfSize:15.0f];
    
    // 4. remove flag button's target
    self.flagBtn.frame = self.flagRect.frame;
    [self.flagBtn removeTarget:self action:@selector(flagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showGoToServiceArea {
    // 0. change the view
    self.frame = CGRectMake((DEVICE_WIDTH - FLAG_WIDTH_GO_TO_SERIVCE_AREA) / 2, (DEVICE_HEIGHT - 64) / 2 - FLAG_RECT_HEIGHT * 2,
                            FLAG_WIDTH_GO_TO_SERIVCE_AREA, FLAG_RECT_HEIGHT * 2);
    // 1. change the rect
    self.flagRect.frame = CGRectMake(0, 0, self.frame.size.width, FLAG_RECT_HEIGHT);
    self.flagRect.backgroundColor = [[LibraryAPI sharedInstance] themeBlueColor];
    
    // 2. change the line color
    self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                     self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                     2, FLAG_RECT_HEIGHT);
    self.flagLine.backgroundColor = self.flagRect.backgroundColor;
    
    // 3. change the text
    self.flagLabel.frame = self.flagRect.frame;
    self.flagLabel.text = @"Go To Service Area";
    self.flagLabel.font = [UIFont systemFontOfSize:13.0f];
    
    // 4. add flag button's target
    self.flagBtn.frame = self.flagRect.frame;
    [self.flagBtn addTarget:self action:@selector(flagBtnClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)hideInMapView:(GMSMapView *)mapView {
    self.frame = CGRectMake(self.frame.origin.x, 0 - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)flagBtnClicked {
    [self.delegate flagBtnClicked];
}

@end
