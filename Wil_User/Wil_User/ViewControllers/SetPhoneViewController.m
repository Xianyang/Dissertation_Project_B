//
//  SetPhoneViewController.m
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define MAXLENGTH 11

#import "SetPhoneViewController.h"
#import "InputCodeViewController.h"

static NSString const *phonePrefix = @"+86";

@interface SetPhoneViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *subInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;

@end

@implementation SetPhoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (IBAction)cancel:(id)sender {
    // TODO delete this user
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendCodeBtnClicked {
    // create an user locally and create this user on the server
    AVUser *user = [AVUser user];
    
    NSString *phone = [self.phoneNumberTextField text];
    user.username = [@"Wil_Default_Name_" stringByAppendingString:phone];
//    user.mobilePhoneNumber = [phonePrefix stringByAppendingString:phone];
    user.mobilePhoneNumber = phone;
    user.password = @"Wil_Default_Password";
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.sendCodeBtn setDisableStatus];
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"sign up successfully");
            
            // request a verification code for this user
            [AVUser requestMobilePhoneVerify:user.mobilePhoneNumber withBlock:^(BOOL succeeded, NSError *error) {
                if(succeeded || error.code == 601){
                    NSLog(@"sms text sent successfully");
                    // go to next vc
                    InputCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputCodeViewController"];
                    [vc setPhoneNumber:phone];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                    [hud hideAnimated:YES];
                } else {
                    // TODO delete this user on the server
                    
                    
                    [hud showErrorMessage:error process:@"requesting verification code"];
                    [self.sendCodeBtn setEnableStatus];
                }
            }];
        } else {
            [hud showErrorMessage:error process:@"signing up"];
            [self.sendCodeBtn setEnableStatus];
        }
    }];
}

# pragma mark - Basic Settings

// set the length limit of textfield to MAXLENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= MAXLENGTH || returnKey;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.phoneNumberTextField.text.length < 8) {
        [self.sendCodeBtn setDisableStatus];
    } else {
        [self.sendCodeBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.phoneNumberTextField becomeFirstResponder];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.sendCodeBtn addTarget:self action:@selector(sendCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCodeBtn setDisableStatus];
    [self.sendCodeBtn.layer setMasksToBounds:YES];
    [self.sendCodeBtn.layer setCornerRadius:self.sendCodeBtn.frame.size.height / 2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
