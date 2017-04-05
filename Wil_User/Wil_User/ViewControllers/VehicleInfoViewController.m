//
//  VehicleInfoViewController.m
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "VehicleInfoViewController.h"

@interface VehicleInfoViewController ()
@property (weak, nonatomic) IBOutlet UITextField *plateTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) OrderObject *order;

@property (strong, nonatomic) NSString *plate;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) NSString *imageURL;

@end

@implementation VehicleInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateView];
}

- (void)updateView {
    self.plateTextField.text = self.plate;
    self.modelTextField.text = self.model;
    self.colorTextField.text = self.color;
    
    [self.plateTextField setEnabled:NO];
    [self.modelTextField setEnabled:NO];
    [self.colorTextField setEnabled:NO];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.imageView animated:YES];
    [[LibraryAPI sharedInstance] getPhotoWithURL:self.imageURL
                                         success:^(UIImage *image) {
                                             [hud hideAnimated:YES];
                                             self.imageView.image = image;
                                         }
                                            fail:^(NSError *error) {
                                                [hud hideAnimated:YES];
                                            }];
}

- (void)setOrder:(OrderObject *)order Plate:(NSString *)plate model:(NSString *)model color:(NSString *)color imageURL:(NSString *)imageURL {
    self.order = order;
    
    self.plate = plate;
    self.model = model;
    self.color = color;
    self.imageURL = imageURL;
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
