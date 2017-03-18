//
//  ChangeInfoViewContoller.m
//  Wil_User
//
//  Created by xianyang on 18/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ChangeInfoViewContoller.h"

@interface ChangeInfoViewContoller () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelBtn;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) id object;
@property (strong, nonatomic) NSString *infoKey;
@property (strong, nonatomic) NSString *info;
@end

@implementation ChangeInfoViewContoller

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.textField setText:self.info];
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.textField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    
    [self.saveBtn setEnabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.textField resignFirstResponder];
}

- (IBAction)saveBtnClicked:(id)sender {
    // save the object
    [self.object setObject:self.textField.text forKey:self.infoKey];
    
    [self.cancelBtn setEnabled:NO];
    [self.saveBtn setEnabled:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [hud hideAnimated:YES];
            [self.delegate saveSuccessfully];
        } else {
            
            [self.cancelBtn setEnabled:YES];
            [self.saveBtn setEnabled:YES];
            [hud showMessage:@"Save Failed, Try later"];
        }
    }];
}

- (IBAction)cancelBtnClicked:(id)sender {
    [self.delegate cancelBtnClicked];
}

- (void)setkey:(NSString *)key object:(id)object {
    self.infoKey = key;
    self.info = [object objectForKey:key];
    self.object = object;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if ([textField.text isEqualToString:self.info]) {
        [self.saveBtn setEnabled:NO];
    } else {
        [self.saveBtn setEnabled:YES];
    }
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
