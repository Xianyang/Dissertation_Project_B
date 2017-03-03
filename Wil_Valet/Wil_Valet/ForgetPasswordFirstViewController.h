//
//  ForgetPasswordFirstViewController.h
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ForgetPasswordFirstVCDelegate

- (void)doneProcessInForgetPasswordFirstVC;

@end

@interface ForgetPasswordFirstViewController : UIViewController

@property (assign, nonatomic) id <ForgetPasswordFirstVCDelegate> delegate;

@end
