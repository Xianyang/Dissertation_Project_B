//
//  SetPhoneViewController.h
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SetPhoneVCDelegate

- (void)doneProcessInSetPhoneVC;

@end

@interface SetPhoneViewController : UIViewController

@property (assign, nonatomic) id <SetPhoneVCDelegate> delegate;

@end
