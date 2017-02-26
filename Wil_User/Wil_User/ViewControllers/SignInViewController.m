//
//  SignInViewController.m
//  Wil_User
//
//  Created by xianyang on 26/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "SignInViewController.h"
#import "ForgetPasswordFirstViewController.h"

@interface SignInViewController () <ForgetPasswordFirstVCDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInBtn;
@property (weak, nonatomic) IBOutlet UIButton *forgetPasswordBtn;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (IBAction)cancel:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)forgetPasswordBtnClicked {
    ForgetPasswordFirstViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ForgetPasswordFirstViewController"];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doneProcessInForgetPasswordFirstVC {
    [self.delegate doneProcessInSignInVC];
}

- (void)signInBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.signInBtn setDisableStatus];
    
    [AVUser logInWithMobilePhoneNumberInBackground:self.phoneNumberTextField.text
                                          password:self.passwordTextField.text
                                             block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                                                 if (user && !error) {
                                                     // sign in sucessfully
                                                     [self.phoneNumberTextField resignFirstResponder];
                                                     [self.passwordTextField resignFirstResponder];
                                                     
                                                     [self.delegate doneProcessInSignInVC];
                                                 } else {
                                                     [hud showErrorMessage:error process:@"signing in"];
                                                     [self.signInBtn setEnableStatus];
                                                 }
                                             }];
}

# pragma mark - Basic Settings

// set the length limit of textfield to MAXLENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField isEqual:self.phoneNumberTextField]) {
        NSUInteger oldLength = [textField.text length];
        NSUInteger replacementLength = [string length];
        NSUInteger rangeLength = range.length;
        
        NSUInteger newLength = oldLength - rangeLength + replacementLength;
        
        BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
        return newLength <= [[LibraryAPI sharedInstance] maxLengthForPhoneNumber] || returnKey;
    } else {
        return YES;
    }
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.phoneNumberTextField.text.length < 8 || self.passwordTextField.text.length == 0) {
        [self.signInBtn setDisableStatus];
    } else {
        [self.signInBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.phoneNumberTextField becomeFirstResponder];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneNumberTextField setDelegate:self];
    
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.signInBtn addTarget:self
                       action:@selector(signInBtnClicked)
             forControlEvents:UIControlEventTouchUpInside];
    
    [self.signInBtn setDisableStatus];
    [self.signInBtn.layer setMasksToBounds:YES];
    [self.signInBtn.layer setCornerRadius:self.signInBtn.frame.size.height / 2];
    
    [self.forgetPasswordBtn addTarget:self
                               action:@selector(forgetPasswordBtnClicked)
                     forControlEvents:UIControlEventTouchUpInside];
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
