//
//  MBProgressHUD+WilShowError.m
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MBProgressHUD+WilShowError.h"

@implementation MBProgressHUD (WilShowError)

- (void)showErrorMessage:(NSError *)error process:(NSString *)process{
    NSString *errorMessage = error.userInfo[NSLocalizedDescriptionKey];
    NSLog(@"error while %@: %@", process, errorMessage);
    
    self.mode = MBProgressHUDModeText;
    self.label.text = errorMessage;
    [self hideAnimated:YES afterDelay:2];
}

@end
