//
//  SignUpViewController.m
//  Wil_User
//
//  Created by xianyang on 27/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "SignUpViewController.h"
#import "InputCodeViewController.h"

@interface SignUpViewController () <UITextFieldDelegate, InputCodeVCDelegate>
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (IBAction)cancel:(id)sender {
    [self.firstNameTextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.phoneNumberTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)nextBtnClicked {
    // create an user locally and create this user on the server
    AVUser *user = [AVUser user];
    
    NSString *phone = [self.phoneNumberTextField text];
    user.username = [@"Wil_Default_Name_" stringByAppendingString:phone];
    user.mobilePhoneNumber = [[[LibraryAPI sharedInstance] phonePrefix] stringByAppendingString:phone];
    user.password = self.passwordTextField.text;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.nextBtn setDisableStatus];
    
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
                                                             
                                                             // ********** Step 3 - Update user's name
                                                             
                                                             [user setObject:self.firstNameTextField.text forKey:@"first_name"];
                                                             [user setObject:self.lastNameTextField.text forKey:@"last_name"];
                                                             
                                                             [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                 if (succeeded) {
                                                                     
                                                                     // ********** Step 4 - Request a verification code for this user **********
                                                                     
                                                                     [AVUser requestMobilePhoneVerify:user.mobilePhoneNumber withBlock:^(BOOL succeeded, NSError *error) {
                                                                         
                                                                         // ********** Step 5 - Go to next vc IN ANY CASE **********
                                                                         
                                                                         InputCodeViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputCodeViewController"];
                                                                         [vc setPhoneNumber:phone];
                                                                         vc.delegate = self;
                                                                         [self.navigationController pushViewController:vc animated:YES];
                                                                         
                                                                         [hud hideAnimated:YES];
                                                                     }];
                                                                 } else {
                                                                     // there should no error here
                                                                     [hud showErrorMessage:error process:@"saving user's name"];
                                                                     [self.nextBtn setEnableStatus];
                                                                 }
                                                             }];
                                                         } else {
                                                             [hud showErrorMessage:error process:@"signing in"];
                                                             [self.nextBtn setEnableStatus];
                                                         }
                                                     }];
            
        } else {
            [hud showErrorMessage:error process:@"signing up"];
            [self.nextBtn setEnableStatus];
        }
    }];
}

- (void)doneProcessInInputCodeVC {
    [self.delegate doneProcessInSignUpVC];
}

# pragma mark - Basic Settings

// set the length limit of textfield to MAXLENGTH
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger maxLength = 100;
    
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
        self.passwordTextField.text.length < [[LibraryAPI sharedInstance] minLengthForPassword] ||
        self.firstNameTextField.text.length == 0 || self.lastNameTextField.text.length == 0) {
        [self.nextBtn setDisableStatus];
    } else {
        [self.nextBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.firstNameTextField becomeFirstResponder];
    
    [self.firstNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.lastNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.phoneNumberTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.phoneNumberTextField setDelegate:self];
    [self.passwordTextField setDelegate:self];
    
    [self.nextBtn addTarget:self action:@selector(nextBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.nextBtn setDisableStatus];
    [self.nextBtn.layer setMasksToBounds:YES];
    [self.nextBtn.layer setCornerRadius:self.nextBtn.frame.size.height / 2];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
