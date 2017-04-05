//
//  TakeVehicleImageViewController.m
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "TakeVehicleImageViewController.h"
#import "SWGApiClient.h"
#import "SWGConfiguration.h"
// load models
#import "SWGCoordinate.h"
#import "SWGInlineResponse200.h"
#import "SWGInlineResponse200ProcessingTime.h"
#import "SWGInlineResponse400.h"
#import "SWGPlateCandidate.h"
#import "SWGPlateDetails.h"
#import "SWGRegionOfInterest.h"
#import "SWGVehicleCandidate.h"
#import "SWGVehicleDetails.h"
// load API classes for accessing endpoints
#import "SWGDefaultApi.h"
#import "VehicleInfoViewController.h"

@interface TakeVehicleImageViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;
@property (strong, nonatomic) OrderObject *order;
@property (strong, nonatomic) CLLocation *currentLocation;
@end

@implementation TakeVehicleImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.takePhotoBtn.layer.masksToBounds = YES;
    self.takePhotoBtn.layer.cornerRadius = self.takePhotoBtn.frame.size.height / 2;
    [self.takePhotoBtn addTarget:self action:@selector(takePhotoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn.enabled = NO;
}

- (void)setOrderObject:(OrderObject *)order currentLocation:(CLLocation *)currentLocation {
    self.order = order;
    self.currentLocation = currentLocation;
}

- (void)takePhotoBtnClicked {
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        NSLog(@"Can not find camera");
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:@"public.image"])
    {
        UIImage *image = info[@"UIImagePickerControllerEditedImage"];
        self.imageView.image = image;
        [self dismissViewControllerAnimated:YES completion:nil];
        self.confirmBtn.enabled = YES;
        [self.takePhotoBtn setTitle:@"Retake" forState:UIControlStateNormal];
    }
}

- (IBAction)confirmBtnClicked:(id)sender {
    NSString *imageBytes = [UIImagePNGRepresentation(self.imageView.image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString *secretKey = @"sk_4dcb252bf2e25491a10951ad";
    NSString *country = @"gb";
    NSNumber *recognizeVehicle = @1;
    NSString *state = @"";
    NSNumber *returnImage = @0;
    NSNumber *topn = @10;
    NSString *prewarp = @"";
    
    SWGDefaultApi *apiInstance = [[SWGDefaultApi alloc] init];
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.confirmBtn.enabled = NO;
    [self.takePhotoBtn setDisableStatus];
    
    [apiInstance recognizeBytesWithImageBytes:imageBytes
                                    secretKey:secretKey
                                      country:country
                             recognizeVehicle:recognizeVehicle
                                        state:state
                                  returnImage:returnImage
                                         topn:topn
                                      prewarp:prewarp
                            completionHandler: ^(SWGInlineResponse200* output, NSError* error) {
                                NSString *plate = @"";
                                NSString *model = @"";
                                NSString *color = @"";
                                
                                if (output) {
                                    if (output.results.count) {
                                        SWGPlateDetails *plateDetails = output.results[0];
                                        plate = plateDetails.plate;
                                        
                                        if (plateDetails.vehicle.make.count) {
                                            SWGVehicleCandidate *candidate = plateDetails.vehicle.make[0];
                                            model = candidate.name;
                                        }
                                        
                                        if (plateDetails.vehicle.color.count) {
                                            SWGVehicleCandidate *candidate = plateDetails.vehicle.color[0];
                                            color = candidate.name;
                                        }
                                    }
                                }
                                
                                // update this image to leancloud
                                [[LibraryAPI sharedInstance] uploadFile:[AVFile fileWithData:UIImagePNGRepresentation(self.imageView.image)]
                                                                success:^(NSString *fileURL) {
                                                                    // save the image url to order
                                                                    self.order.vehicle_image_url = fileURL;
                                                                    [self.order saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                                                                        if (succeeded) {
                                                                            NSLog(@"success");
                                                                            NSLog(@"%@, %@, %@", plate, model, color);
                                                                            [hud hideAnimated:YES];
                                                                            self.confirmBtn.enabled = YES;
                                                                            [self.takePhotoBtn setEnableStatus];
                                                                            
                                                                            // push to next view
                                                                            VehicleInfoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VehicleInfoViewController"];
                                                                            [vc setOrder:self.order currentLocation:self.currentLocation Plate:plate model:model color:color image:self.imageView.image imageURL:fileURL editable:YES];
                                                                            [self.navigationController pushViewController:vc animated:YES];
                                                                        } else {
                                                                            [hud showMessage:@"save order failed, try again"];
                                                                            self.confirmBtn.enabled = YES;
                                                                            [self.takePhotoBtn setEnableStatus];
                                                                        }
                                                                    }];
                                                                }
                                                                   fail:^(NSError *error) {
                                                                       [hud showMessage:@"upload image failed, try again"];
                                                                       self.confirmBtn.enabled = YES;
                                                                       [self.takePhotoBtn setEnableStatus];
                                                                   }];
                            }];
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
