//
//  InputCodeViewController.m
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "InputCodeViewController.h"
#import "UIButton+Status.h"

@interface InputCodeViewController () <UITextFieldDelegate>
@property (strong, nonatomic) NSString *phone;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *subInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitCodeBtn;

@end

@implementation InputCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.subInfoLabel.text = [@"Please fill in the code for " stringByAppendingString:self.phone];
    [self basicSettings];
}

- (IBAction)skip:(id)sender {
    [self.codeTextField resignFirstResponder];
    [self.delegate doneProcessInInputCodeVC];
}

- (void)setPhoneNumber:(NSString *)phone {
    self.phone = phone;
}

- (void)submitCodeBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.submitCodeBtn setDisableStatus];
    
    [AVUser verifyMobilePhone:self.codeTextField.text
                    withBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            [hud hideAnimated:YES];
                            NSLog(@"sms code verify successfully");
                            
                            // Go to main view
                            [self.codeTextField resignFirstResponder];
                            [self.delegate doneProcessInInputCodeVC];
                        } else {
                            [self.submitCodeBtn setEnableStatus];
                            [hud showErrorMessage:error process:@"verifying verification code"];
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
    
    return newLength <= [[LibraryAPI sharedInstance] maxLengthForVerificationCode] || returnKey;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.codeTextField.text.length < 6) {
        [self.submitCodeBtn setDisableStatus];
    } else {
        [self.submitCodeBtn setEnableStatus];
    }
}

- (void)basicSettings {
    [self.codeTextField becomeFirstResponder];
    [self.codeTextField setDelegate:self];
    [self.codeTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.submitCodeBtn.layer setMasksToBounds:YES];
    [self.submitCodeBtn.layer setCornerRadius:self.codeTextField.frame.size.height / 2];
    [self.submitCodeBtn addTarget:self action:@selector(submitCodeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.submitCodeBtn setDisableStatus];
    
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
