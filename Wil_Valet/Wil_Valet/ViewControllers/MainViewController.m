//
//  MainViewController.m
//  Wil_Valet
//
//  Created by xianyang on 02/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MainViewController.h"
#import "SignInViewController.h"
#import "ValetLocation.h"

static NSString * const ValetLocationClassName = @"Valet_Location";

@interface MainViewController () <SignInVCDelegate, CLLocationManagerDelegate> {
    BOOL _isSignInAnimated;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) ValetLocation *valetLocation;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self checkCurrentUser];
    [[LibraryAPI sharedInstance] saveValetLocationObjectID:@""];
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
        
        if (self.valetLocation.objectId == nil) {
            // 1. query from the server
            AVUser *valet = [AVUser currentUser];
            
            AVQuery *query = [AVQuery queryWithClassName:ValetLocationClassName];
            [query whereKey:@"valet_object_ID" equalTo:valet.objectId];
            [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
                if (objects.count == 1 && !error) {
                    self.valetLocation = objects[0];
                    
                    // 2. update location
                    
                    self.valetLocation.valet_location = geoPoint;
                    [self.valetLocation saveInBackground];
                    
                    // 3. save the objectID
                    [[LibraryAPI sharedInstance] saveValetLocationObjectID:self.valetLocation.objectId];
                } else {
                    // 2. create this ValetLocation object
                    self.valetLocation.valet_location = geoPoint;
                    self.valetLocation.valet_object_ID = valet.objectId;
                    self.valetLocation.valet_first_name = [valet objectForKey:@"first_name"];
                    self.valetLocation.valet_last_name = [valet objectForKey:@"last_name"];
                    self.valetLocation.valet_mobile_phone_numer = valet.mobilePhoneNumber;
                    self.valetLocation.valet_user_name = valet.username;
                    
                    [self.valetLocation saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            // 3. save the objectID
                            [[LibraryAPI sharedInstance] saveValetLocationObjectID:self.valetLocation.objectId];
                        } else {
                            
                        }
                    }];
                }
            }];
        } else {
            self.valetLocation.valet_location = geoPoint;
            [self.valetLocation saveInBackground];
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
    [self.locationManager startMonitoringSignificantLocationChanges];
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

- (ValetLocation *)valetLocation {
    if (!_valetLocation) {
        NSString *valetLocationObjectID = [[LibraryAPI sharedInstance] valetLocationObjectID];
        if (valetLocationObjectID && ![valetLocationObjectID isEqualToString:@""]) {
            _valetLocation = [ValetLocation objectWithObjectId:valetLocationObjectID];
        } else {
            _valetLocation = [ValetLocation object];
        }
    }
    
    return _valetLocation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
