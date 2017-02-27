//
//  SignUpViewController.h
//  Wil_User
//
//  Created by xianyang on 27/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SignUpVCDelegate

- (void)doneProcessInSignUpVC;

@end

@interface SignUpViewController : UIViewController

@property (assign, nonatomic) id <SignUpVCDelegate> delegate;

@end
