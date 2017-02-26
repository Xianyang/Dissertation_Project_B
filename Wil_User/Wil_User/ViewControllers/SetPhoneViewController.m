//
//  SetPhoneViewController.m
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "SetPhoneViewController.h"
#import "InputCodeViewController.h"

@interface SetPhoneViewController () <UITextFieldDelegate, InputCodeVCDelegate>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *subInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
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
    user.mobilePhoneNumber = [[[LibraryAPI sharedInstance] phonePrefix] stringByAppendingString:phone];
//    user.mobilePhoneNumber = phone;
    user.password = self.passwordTextField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.sendCodeBtn setDisableStatus];
    
    // ********** Step 1 - Create this user on the server by **********
    // @param username
    // @param mobile phone number
    // @param password
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"sign up successfully");
            
            // ********** Step 2 - Using mobile phone number and password to log in this user **********
            
            [AVUser logInWithMobilePhoneNumberInBackground:user.mobilePhoneNumber
                                                  password:self.passwordTextField.text
                                                     block:^(AVUser * _Nullable user, NSError * _Nullable error) {
                                                         if (user && !error) {
                                                             
                                                             // ********** Step 3 - Request a verification code for this user **********
                                                             
                                                             [AVUser requestMobilePhoneVerify:user.mobilePhoneNumber withBlock:^(BOOL succeeded, NSError *error) {
                                                                 if(succeeded || error.code == 601){
                                                                     NSLog(@"sms text sent successfully");
                                                                     
                                                                     // ********** Step 4 - Go to next vc **********
                                                                     
                                                                     InputCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputCodeViewController"];
                                                                     [vc setPhoneNumber:phone password:self.passwordTextField.text];
                                                                     vc.delegate = self;
                                                                     [self.navigationController pushViewController:vc animated:YES];
                                                                     
                                                                     [hud hideAnimated:YES];
                                                                 } else {
                                                                     
                                                                     [hud showErrorMessage:error process:@"requesting verification code"];
                                                                     [self.sendCodeBtn setEnableStatus];
                                                                 }
                                                             }];
                                                         } else {
                                                             [hud showErrorMessage:error process:@"signing in"];
                                                             [self.sendCodeBtn setEnableStatus];
                                                         }
                                                     }];
            
        } else {
            [hud showErrorMessage:error process:@"signing up"];
            [self.sendCodeBtn setEnableStatus];
        }
    }];
}

- (void)doneProcessInInputCodeVC {
    [self.delegate doneProcessInSetPhoneVC];
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
        [self.sendCodeBtn setDisableStatus];
    } else {
        [self.sendCodeBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.phoneNumberTextField becomeFirstResponder];
    [self.phoneNumberTextField setDelegate:self];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.passwordTextField setDelegate:self];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.sendCodeBtn addTarget:self action:@selector(sendCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCodeBtn setDisableStatus];
    [self.sendCodeBtn.layer setMasksToBounds:YES];
    [self.sendCodeBtn.layer setCornerRadius:self.sendCodeBtn.frame.size.height / 2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
