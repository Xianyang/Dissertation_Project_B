//
//  InputUserInfoViewController.h
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputUserInfoVCDelegate

- (void)doneProcessInInputUserInfoVC;

@end

@interface InputUserInfoViewController : UIViewController

@property (assign, nonatomic) id <InputUserInfoVCDelegate> delegate;

@end
