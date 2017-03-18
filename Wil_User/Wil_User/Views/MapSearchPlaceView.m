//
//  MapSearchPlaceView.m
//  Wil_User
//
//  Created by xianyang on 18/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define SEARCH_IMAGE_ORIGIN_X 10
#define SEARCH_IMAGE_ORIGIN_Y 10

#import "MapSearchPlaceView.h"

@interface MapSearchPlaceView ()

@property (assign, nonatomic) CGRect originRect;
@property (strong, nonatomic) UIImageView *searchImageView;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIButton *searchBtn;
@property (strong, nonatomic) UILabel *addressLabel;

@end

@implementation MapSearchPlaceView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        self.originRect = frame;
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
        self.searchImageView = [[UIImageView alloc] initWithFrame:CGRectMake(SEARCH_IMAGE_ORIGIN_X, SEARCH_IMAGE_ORIGIN_Y, self.frame.size.height - 2 * SEARCH_IMAGE_ORIGIN_Y, self.frame.size.height - 2 * SEARCH_IMAGE_ORIGIN_Y)];
        self.lineView = [[UIView alloc] initWithFrame:CGRectMake(self.searchImageView.frame.origin.x + self.searchImageView.frame.size.width + 10, SEARCH_IMAGE_ORIGIN_Y
                                                                 , 1, self.searchImageView.frame.size.height)];
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.lineView.frame.origin.x + self.lineView.frame.size.width + 10, SEARCH_IMAGE_ORIGIN_Y,
                                                                      self.frame.size.width - self.lineView.frame.origin.x - self.lineView.frame.size.width - 2 * 10, self.searchImageView.frame.size.height)];
        self.searchBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        
        [self addSubview:self.searchImageView];
        [self addSubview:self.lineView];
        [self addSubview:self.addressLabel];
        [self addSubview:self.searchBtn];
        
        self.searchImageView.image = [UIImage imageNamed:@"search"];
        [self setDefaultTitle];
        self.addressLabel.textColor = [UIColor blackColor];
        [self.searchBtn addTarget:self action:@selector(searchBtnCLicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return self;
}

- (void)searchBtnCLicked {
    [self.delegate searchBtnClicked];
}

- (void)setDefaultTitle {
    self.addressLabel.text = @"Where should we meet?";
    self.addressLabel.textColor = [UIColor lightGrayColor];
}

- (void)setParkAddress:(NSString *)parkAddress {
    if ([parkAddress isEqualToString:@""] || !parkAddress) {
        [self setDefaultTitle];
    } else {
        self.addressLabel.text = parkAddress;
        self.addressLabel.textColor = [UIColor blackColor];
    }
}

- (void)show {
    self.frame = CGRectMake(self.frame.origin.x, 10, self.frame.size.width, self.frame.size.height);
}

- (void)hide {
    self.frame = CGRectMake(self.frame.origin.x, - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
