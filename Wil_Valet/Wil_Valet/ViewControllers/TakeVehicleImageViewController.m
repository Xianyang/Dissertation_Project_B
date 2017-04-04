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

@interface TakeVehicleImageViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *confirmBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoBtn;

@end

@implementation TakeVehicleImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.takePhotoBtn.layer.masksToBounds = YES;
    self.takePhotoBtn.layer.cornerRadius = self.takePhotoBtn.frame.size.height / 2;
    [self.takePhotoBtn addTarget:self action:@selector(takePhotoBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn.enabled = NO;
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
    
    [apiInstance recognizeBytesWithImageBytes:imageBytes
                                    secretKey:secretKey
                                      country:country
                             recognizeVehicle:recognizeVehicle
                                        state:state
                                  returnImage:returnImage
                                         topn:topn
                                      prewarp:prewarp
                            completionHandler: ^(SWGInlineResponse200* output, NSError* error) {
                                if (output) {
                                    [hud hideAnimated:YES];
                                    NSLog(@"%@", output);
                                }
                                if (error) {
                                    [hud hideAnimated:YES];
                                    NSLog(@"Error: %@", error);
                                }
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
