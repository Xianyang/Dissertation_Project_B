//
//  ForgetPasswordSecondViewController.m
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ForgetPasswordSecondViewController.h"

@interface ForgetPasswordSecondViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UILabel *subInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation ForgetPasswordSecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (void)submitBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.submitBtn setDisableStatus];
    
    // ********** Step 1 - Reset password by verification code and a new password
    
    [AVUser resetPasswordWithSmsCode:self.codeTextField.text
                         newPassword:self.passwordTextField.text
                               block:^(BOOL succeeded, NSError * _Nullable error) {
                                   if (succeeded) {
                                       
                                       // ********** Step 2 - Log in this user **********
                                       
                                       [AVUser logInWithMobilePhoneNumberInBackground:[[[LibraryAPI sharedInstance] phonePrefix] stringByAppendingString:self.phone]
                                                                             password:self.passwordTextField.text
                                                                                block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                                                                                    if (user && !error) {
                                                                                        // sign in sucessfully
                                                                                        [self.codeTextField resignFirstResponder];
                                                                                        [self.passwordTextField resignFirstResponder];
                                                                                        
                                                                                        [hud hideAnimated:YES];
                                                                                        [self.delegate doneProcessInForgetPasswordSecondVC];
                                                                                    } else {
                                                                                        // there should be no problems here
                                                                                    }
                                                                                }];
                                       
                                       
                                   } else {
                                       [self.submitBtn setEnableStatus];
                                       [hud showErrorMessage:error process:@"resetting password"];
                                   }
                               }];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)setPhoneNumber:(NSString *)phone {
    self.phone = phone;
}

// set the length limit of textfield to MAXLENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.codeTextField]) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= [[LibraryAPI sharedInstance] maxLengthForVerificationCode] || returnKey;
    } else {
        return YES;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.codeTextField.text.length < [[LibraryAPI sharedInstance] maxLengthForVerificationCode] ||
        self.passwordTextField.text.length < [[LibraryAPI sharedInstance] minLengthForPassword]) {
        [self.submitBtn setDisableStatus];
    } else {
        [self.submitBtn setEnableStatus];
    }
}


- (void)basicSettings {
    self.subInfoLabel.text = [@"Please fill in the code for " stringByAppendingString:self.phone];
    [self.codeTextField becomeFirstResponder];
    [self.codeTextField setDelegate:self];
    [self.codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn setDisableStatus];
    [self.submitBtn.layer setMasksToBounds:YES];
    [self.submitBtn.layer setCornerRadius:self.submitBtn.frame.size.height / 2];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
