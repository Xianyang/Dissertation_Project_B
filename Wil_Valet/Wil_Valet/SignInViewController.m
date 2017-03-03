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
    
    [AVUser logOut];
    
    AVUser *user = [AVUser user];
    user.username = @"admin_valet";
    user.mobilePhoneNumber = @"+85251709669";
    user.password = @"123456";
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"sign up!");
            [AVUser requestMobilePhoneVerify:user.mobilePhoneNumber
                                   withBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                       if (succeeded) {
                                           NSLog(@"lalal");
                                       } else {
                                           NSLog(@"???");
                                       }
                                   }];
        } else {
            NSLog(@"error");
        }

    }];
    
//    AVUser *user = [AVUser currentUser];
//    [AVUser requestMobilePhoneVerify:[[AVUser currentUser] mobilePhoneNumber]
//                           withBlock:^(BOOL succeeded, NSError * _Nullable error) {
//                               if (succeeded) {
//                                   NSLog(@"lalal");
//                               } else {
//                                   NSLog(@"???");
//                               }
//                           }];
}

- (IBAction)signUp:(id)sender {
    [AVUser verifyMobilePhone:self.phoneNumberTextField.text
                    withBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            NSLog(@"good");
                        } else {
                            NSLog(@"error");
                        }
    }];
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
    
    [AVUser logInWithMobilePhoneNumberInBackground:[[[LibraryAPI sharedInstance] phonePrefix] stringByAppendingString:self.phoneNumberTextField.text]
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
    NSInteger maxLength = 0;
    
    if ([textField isEqual:self.phoneNumberTextField]) {
        maxLength = [[LibraryAPI sharedInstance] maxLengthForPhoneNumber];
    } else if ([textField isEqual:self.passwordTextField]) {
        maxLength = [[LibraryAPI sharedInstance] maxLengthForPassword];
    }
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    return newLength <= maxLength || returnKey;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.phoneNumberTextField.text.length < [[LibraryAPI sharedInstance] minLengthForPhoneNumber] ||
        self.passwordTextField.text.length < [[LibraryAPI sharedInstance] minLengthForPassword]) {
        [self.signInBtn setDisableStatus];
    } else {
        [self.signInBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.phoneNumberTextField becomeFirstResponder];
    [self.phoneNumberTextField setDelegate:self];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordTextField setDelegate:self];
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
