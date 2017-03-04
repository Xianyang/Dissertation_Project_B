//
//  MainViewController.m
//  Wil_Valet
//
//  Created by xianyang on 02/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MainViewController.h"
#import "SignInViewController.h"

static NSString * const ValetLocationClassName = @"Valet_Location";

@interface MainViewController () <SignInVCDelegate, CLLocationManagerDelegate> {
    BOOL _isSignInAnimated;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) AVObject *locationObject;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self checkCurrentUser];
}





- (void)getCurrentOrders {
    
}

#pragma mark - Location Service

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count) {
        CLLocation *location = locations[0];
        NSLog(@"latitude:%f, longitude:%f", location.coordinate.latitude, location.coordinate.longitude);
        self.locationLabel.text = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
        AVGeoPoint *geoPoint = [AVGeoPoint geoPointWithLocation:location];
        
        // TODO update location to server
        if (self.locationObject.objectId == nil) {
            // 1. query from the server
            AVUser *valet = [AVUser currentUser];
            
            AVQuery *query = [AVQuery queryWithClassName:ValetLocationClassName];
            [query whereKey:@"valetPhoneNumer" equalTo:valet.mobilePhoneNumber];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (objects.count == 1 && !error) {
                    self.locationObject = objects[0];
                    
                    // 2. update location
                    
                    [self.locationObject setObject:geoPoint forKey:@"location"];
                    [self.locationObject saveInBackground];
                    
                    // 3. save the objectID
                    [[LibraryAPI sharedInstance] saveValetLocationObjectID:self.locationObject.objectId];
                } else {
                    // 2. create this ValetLocation object
                    [self.locationObject setObject:geoPoint forKey:@"location"];
                    [self.locationObject setObject:[valet objectForKey:@"first_name"] forKey:@"valet_first_name"];
                    [self.locationObject setObject:[valet objectForKey:@"last_name"] forKey:@"valet_last_name"];
                    [self.locationObject setObject:valet.mobilePhoneNumber forKey:@"valet_mobile_phone_number"];
                    [self.locationObject setObject:valet.username forKey:@"valet_user_name"];
                    
                    [self.locationObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            // 3. save the objectID
                            [[LibraryAPI sharedInstance] saveValetLocationObjectID:self.locationObject.objectId];
                        } else {
                            
                        }
                    }];
                }
            }];
        } else {
            [self.locationObject setObject:geoPoint forKey:@"location"];
            [self.locationObject saveInBackground];
        }
    }
}

- (void)requestLocationService {
    // 1. check authorization status
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    
    if (status == kCLAuthorizationStatusNotDetermined) {
        [self.locationManager requestAlwaysAuthorization];
    } else if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"We need your location"
                                                                       message:@"Customers need to find valets"
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self.locationManager requestAlwaysAuthorization];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    // 2. get valet's location
    self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    self.locationManager.distanceFilter = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

#pragma mark - Sign in view controller delegate

- (void)doneProcessInSignInVC {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self requestLocationService];
    [self getCurrentOrders];
}

#pragma mark - User

- (void)checkCurrentUser {
    // if there is no user now, show the Instruction page
    if (![AVUser currentUser]) {
        UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInVCNav"];
        SignInViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        [self presentViewController:navVC animated:_isSignInAnimated completion:nil];
    } else {
        // current user is not nil
        [self requestLocationService];
        [self getCurrentOrders];
    }
}

#pragma mark - Some Settings

- (void)setNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gill Sans-UltraBold" size:18], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //    UIBarButtonItem *backButton =
    //    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
    //                                     style:UIBarButtonItemStylePlain
    //                                    target:nil
    //                                    action:nil];
    //    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void)animateSignInView {
    _isSignInAnimated = YES;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (AVObject *)locationObject {
    if (!_locationObject) {
        NSString *valetLocationObjectID = [[LibraryAPI sharedInstance] valetLocationObjectID];
        if (valetLocationObjectID && ![valetLocationObjectID isEqualToString:@""]) {
            _locationObject = [AVObject objectWithClassName:ValetLocationClassName objectId:valetLocationObjectID];
        } else {
            _locationObject = [AVObject objectWithClassName:ValetLocationClassName];
        }
    }
    
    return _locationObject;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
