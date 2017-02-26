//
//  InstructionViewController.h
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InstructionVCDelegate

- (void)doneProcessInInstructionVC;

@end

@interface InstructionViewController : UIViewController

@property (assign, nonatomic) id <InstructionVCDelegate> delegate;

@end
