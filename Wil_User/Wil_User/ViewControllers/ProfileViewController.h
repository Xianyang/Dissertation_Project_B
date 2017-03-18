//
//  ProfileViewController.h
//  Wil_User
//
//  Created by xianyang on 20/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileVCDelegate

- (void)userLogout;


@end

@interface ProfileViewController : UIViewController

@property (assign, nonatomic) id <ProfileVCDelegate> delegate;

@end
