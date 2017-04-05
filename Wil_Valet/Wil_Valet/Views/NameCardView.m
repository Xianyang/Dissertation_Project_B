//
//  NameCardView.m
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "NameCardView.h"

@interface NameCardView () {
    CGRect _originRect;
}

@property (strong, nonatomic) UIButton *cancelBtn;

@end

@implementation NameCardView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _originRect = frame;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5;
        
//        self.backgroundColor = [UIColor greenColor];
        
        // add a background
//        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
//        bgView.backgroundColor = [[LibraryAPI sharedInstance] themeBlueColor];
//        bgView.layer.masksToBounds = YES;
//        bgView.layer.cornerRadius = 5;
//        [self addSubview:bgView];
        
        UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 40)];
        bgImageView.image = [UIImage imageNamed:@"Instruction_Bg"];
        bgImageView.layer.masksToBounds = YES;
        bgImageView.layer.cornerRadius = 5;
        [self addSubview:bgImageView];
        
        // add an image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - 70) / 2, 15, 70, 70)];
        imageView.image = [UIImage imageNamed:@"default_profile_image"];
        imageView.layer.masksToBounds = YES;
        imageView.layer.cornerRadius = imageView.frame.size.width / 2;
        [self addSubview:imageView];
        
        AVUser *user = [AVUser currentUser];
        NSString *fileURL = [user objectForKey:@"profile_image_url"];
        if (fileURL && ![fileURL isEqualToString:@""]) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:imageView animated:YES];
            [[LibraryAPI sharedInstance] getPhotoWithURL:fileURL
                                                 success:^(UIImage *image) {
                                                     [hud hideAnimated:YES];
                                                     imageView.image = image;
                                                 }
                                                    fail:^(NSError *error) {
                                                        
                                                    }];
        }
        
        // add name
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.frame.origin.y + imageView.frame.size.height + 15, self.frame.size.width, 20)];
        nameLabel.font = [UIFont systemFontOfSize:16.0f];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.text = [NSString stringWithFormat:@"%@ %@", [user objectForKey:@"last_name"], [user objectForKey:@"first_name"]];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        
        // add valet
        UILabel *postionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, nameLabel.frame.origin.y + nameLabel.frame.size.height + 5, self.frame.size.width, 20)];
        postionLabel.font = [UIFont systemFontOfSize:16.0f];
        postionLabel.textColor = [UIColor whiteColor];
        postionLabel.text = @"Valet at WIL";
        postionLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:postionLabel];
        
        // add phone
        UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, postionLabel.frame.origin.y + postionLabel.frame.size.height + 5, self.frame.size.width, 20)];
        phoneLabel.font = [UIFont systemFontOfSize:16.0f];
        phoneLabel.textColor = [UIColor whiteColor];
        phoneLabel.text = [user mobilePhoneNumber];
        phoneLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:phoneLabel];
        
        // add slogan
        UILabel *sloganLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, phoneLabel.frame.origin.y + phoneLabel.frame.size.height + 5, self.frame.size.width, 20)];
        sloganLabel.font = [UIFont systemFontOfSize:14.0f];
        sloganLabel.textColor = [UIColor whiteColor];
        sloganLabel.text = @"Happy to Serve you";
        sloganLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:sloganLabel];
        
        // add cancel button
        self.cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.frame.size.width - 40) / 2, self.frame.size.height - 40, 40, 40)];
        [self.cancelBtn setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
        [self.cancelBtn addTarget:self action:@selector(cancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.cancelBtn];
    }
    
    return self;
}

- (void)show {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = CGRectMake(_originRect.origin.x, 120, _originRect.size.width, _originRect.size.height);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)cancelBtnClick {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.frame = _originRect;
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

@end
