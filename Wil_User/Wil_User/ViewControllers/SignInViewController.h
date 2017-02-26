//
//  SignInViewController.h
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignInVCDelegate

- (void)doneProcessInSignInVC;

@end

@interface SignInViewController : UIViewController

@property (assign, nonatomic) id <SignInVCDelegate> delegate;

@end
