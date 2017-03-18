//
//  ChangeInfoViewContoller.h
//  Wil_User
//
//  Created by xianyang on 18/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeInfoViewControllerDelegate

- (void)cancelBtnClicked;
- (void)saveSuccessfully;

@end

@interface ChangeInfoViewContoller : UIViewController

- (void)setkey:(NSString *)key object:(id)object;

@property (assign, nonatomic) id <ChangeInfoViewControllerDelegate> delegate;

@end
