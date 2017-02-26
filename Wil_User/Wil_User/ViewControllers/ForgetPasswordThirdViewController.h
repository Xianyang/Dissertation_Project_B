//
//  ForgetPasswordThirdViewController.h
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ForgetPasswordThirdCDelegate

- (void)doneProcessInForgetPasswordThirdVC;

@end

@interface ForgetPasswordThirdViewController : UIViewController

@property (assign, nonatomic) id <ForgetPasswordThirdCDelegate> delegate;

@end
