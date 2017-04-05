//
//  VehicleInfoViewController.m
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "VehicleInfoViewController.h"

@interface VehicleInfoViewController () {
    BOOL _editable;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBtn;
@property (weak, nonatomic) IBOutlet UITextField *plateTextField;
@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *colorTextField;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) OrderObject *order;
@property (strong, nonatomic) CLLocation *currentLocation;

@property (strong, nonatomic) NSString *plate;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *color;
@property (strong, nonatomic) UIImage *image;
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
    
    if (self.image) {
        self.imageView.image = self.image;
    } else {
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
    
    if (_editable) {
        [self.plateTextField setEnabled:YES];
        [self.modelTextField setEnabled:YES];
        [self.colorTextField setEnabled:YES];
        [self.plateTextField becomeFirstResponder];
    } else {
        [self.plateTextField setEnabled:NO];
        [self.modelTextField setEnabled:NO];
        [self.colorTextField setEnabled:NO];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (IBAction)submitBtnClicked:(id)sender {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([self.plateTextField.text isEqualToString:@""] ||
        [self.modelTextField.text isEqualToString:@""] ||
        [self.colorTextField.text isEqualToString:@""]) {
        [hud showMessage:@"Please complete info"];
        return;
    }
    
    self.order.order_status = kUserOrderStatusParked;
    self.order.vehicle_plate = self.plateTextField.text;
    self.order.vehicle_model = self.modelTextField.text;
    self.order.vehicle_color = self.colorTextField.text;
    self.order.park_at = [NSDate date];
    self.order.parked_location = [AVGeoPoint geoPointWithLocation:self.currentLocation];
    
    // update valetLocation object
    [self.order saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            [hud hideAnimated:YES];
            
            [[LibraryAPI sharedInstance] updateValetServingStatus:NO];
            
            [self.plateTextField resignFirstResponder];
            [self.modelTextField resignFirstResponder];
            [self.colorTextField resignFirstResponder];
            [self.navigationController popToRootViewControllerAnimated:YES];
        } else {
            [hud showMessage:@"fail to update order, try again"];
        }
    }];

}

- (void)setOrder:(OrderObject *)order currentLocation:(CLLocation *)currentLocation Plate:(NSString *)plate model:(NSString *)model color:(NSString *)color image:(UIImage *)image imageURL:(NSString *)imageURL editable:(BOOL)editable {
    self.order = order;
    self.currentLocation = currentLocation;
    
    self.plate = plate;
    self.model = model;
    self.color = color;
    self.image = image;
    self.imageURL = imageURL;
    _editable = editable;
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
