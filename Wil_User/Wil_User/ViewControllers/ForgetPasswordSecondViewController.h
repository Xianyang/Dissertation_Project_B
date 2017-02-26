//
//  ForgetPasswordSecondViewController.h
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ForgetPasswordSecondVCDelegate

- (void)doneProcessInForgetPasswordSecondVC;

@end

@interface ForgetPasswordSecondViewController : UIViewController

@property (assign, nonatomic) id <ForgetPasswordSecondVCDelegate> delegate;

@end
