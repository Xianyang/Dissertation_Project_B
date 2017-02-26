//
//  InputUserInfoViewController.m
//  Wil_User
//
//  Created by xianyang on 25/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "InputUserInfoViewController.h"

@interface InputUserInfoViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UILabel *subInfoLabel;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@end

@implementation InputUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self basicSettings];
}

- (IBAction)cancel:(id)sender {
    // TODO delete this user on server
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)submitBtnClicked {
    [[AVUser currentUser] setObject:self.firstNameTextField.text forKey:@"first_name"];
    [[AVUser currentUser] setObject:self.lastNameTextField.text forKey:@"last_name"];
    
    [[AVUser currentUser] setEmail:self.emailTextField.text];
    
    // start save data
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.submitBtn setDisableStatus];
    [[AVUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [hud hideAnimated:YES];
            NSLog(@"save user's info sucessfully");
            
            [self.firstNameTextField resignFirstResponder];
            [self.lastNameTextField resignFirstResponder];
            [self.emailTextField resignFirstResponder];
            [self.delegate doneProcessInInputUserInfoVC];
        } else {
            [hud showErrorMessage:error process:@"error while saving user's info"];
            [self.submitBtn setEnableStatus];
        }
    }];
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (self.firstNameTextField.text.length > 0 &&
        self.lastNameTextField.text.length > 0 &&
        self.emailTextField.text.length > 0) {
        [self.submitBtn setEnableStatus];
    } else {
        [self.submitBtn setDisableStatus];
    }
}

- (void)basicSettings {
    [self.firstNameTextField becomeFirstResponder];
    [self.firstNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.lastNameTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.emailTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    [self.submitBtn.layer setMasksToBounds:YES];
    [self.submitBtn.layer setCornerRadius:self.submitBtn.frame.size.height / 2];
    [self.submitBtn addTarget:self action:@selector(submitBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.submitBtn setDisableStatus];
    
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
