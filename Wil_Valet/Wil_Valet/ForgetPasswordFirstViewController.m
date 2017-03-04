//
//  ForgetPasswordFirstViewController.m
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ForgetPasswordFirstViewController.h"
#import "ForgetPasswordSecondViewController.h"

@interface ForgetPasswordFirstViewController () <UITextFieldDelegate, ForgetPasswordSecondVCDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;

@end

@implementation ForgetPasswordFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)sendCodeBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.sendCodeBtn setDisableStatus];
    
    [AVUser requestPasswordResetWithPhoneNumber:[[[LibraryAPI sharedInstance] phonePrefix] stringByAppendingString:self.phoneNumberTextField.text]
                                          block:^(BOOL succeeded, NSError * _Nullable error) {
                                              if (succeeded) {
                                                  NSLog(@"sms text sent successfully");
                                                  
                                                  ForgetPasswordSecondViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPasswordSecondViewController"];
                                                  [vc setPhoneNumber:self.phoneNumberTextField.text];
                                                  vc.delegate = self;
                                                  [self.navigationController pushViewController:vc animated:YES];
                                              } else {
                                                  [self.sendCodeBtn setEnableStatus];
                                                  [hud showErrorMessage:error process:@"resetting password"];
                                              }
                                          }];
}

- (void)doneProcessInForgetPasswordSecondVC {
    [self.delegate doneProcessInForgetPasswordFirstVC];
}

# pragma mark - Basic Settings

// set the length limit of textfield to MAXLENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= [[LibraryAPI sharedInstance] maxLengthForPhoneNumber] || returnKey;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.phoneNumberTextField.text.length < [[LibraryAPI sharedInstance] minLengthForPhoneNumber]) {
        [self.sendCodeBtn setDisableStatus];
    } else {
        [self.sendCodeBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.phoneNumberTextField becomeFirstResponder];
    [self.phoneNumberTextField setDelegate:self];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.sendCodeBtn addTarget:self action:@selector(sendCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCodeBtn setDisableStatus];
    [self.sendCodeBtn.layer setMasksToBounds:YES];
    [self.sendCodeBtn.layer setCornerRadius:self.sendCodeBtn.frame.size.height / 2];
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
