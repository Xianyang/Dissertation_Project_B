//
//  InputCodeViewController.h
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InputCodeVCDelegate

- (void)doneProcessInInputCodeVC;

@end

@interface InputCodeViewController : UIViewController

- (void)setPhoneNumber:(NSString *)phone;

@property (assign, nonatomic) id <InputCodeVCDelegate> delegate;

@end
