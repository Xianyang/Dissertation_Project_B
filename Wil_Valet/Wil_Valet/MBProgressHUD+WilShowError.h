//
//  MBProgressHUD+WilShowError.h
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <MBProgressHUD/MBProgressHUD.h>

@interface MBProgressHUD (WilShowError)

- (void)showErrorMessage:(NSError *)error process:(NSString *)process;
- (void)showMessage:(NSString *)message;

@end
