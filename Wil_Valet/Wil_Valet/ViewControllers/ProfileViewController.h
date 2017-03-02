//
//  ProfileViewController.h
//  Wil_Valet
//
//  Created by xianyang on 02/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfileVCDelegate

- (void)userLogout;

@end

@interface ProfileViewController : UIViewController

@property (assign, nonatomic) id <ProfileVCDelegate> delegate;

@end
