//
//  MainViewController.m
//  Wil_Valet
//
//  Created by xianyang on 02/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MainViewController.h"
#import "SignInViewController.h"
#import "OrderDetailViewController.h"
#import "ValetLocation.h"
#import "OrderObject.h"
#import "OrderCell.h"
#import "ClientObject.h"


static NSString * const OrderCellIdentifier = @"OrderCell";

@interface MainViewController () <SignInVCDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource> {
    BOOL _isSignInAnimated;
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *currentDropOrders;
@property (strong, nonatomic) NSArray *currentReturnOrders;

@property (strong, nonatomic) NSTimer *refreshOrderTimer;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self checkCurrentUser];
    [[LibraryAPI sharedInstance] resetValetLocationObjectID];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AVUser currentUser]) {
        [self.refreshOrderTimer setFireDate:[NSDate date]];
        [self getCurrentOrders];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.refreshOrderTimer setFireDate:[NSDate distantFuture]];
}

- (IBAction)refreshBtnClicked:(id)sender {
    [self getCurrentOrders];
}

- (void)getCurrentOrders {
    [[LibraryAPI sharedInstance] fetchCurrentDropOrder:^(NSArray *orders) {
        self.currentDropOrders = orders;
        [self.tableView reloadData];
    }
                                                  fail:^(NSError *error) {
                                                      if (self.currentDropOrders.count > 0) {
                                                          self.currentDropOrders = @[];
                                                          [self.tableView reloadData];
                                                      }
                                                      
                                                      [self showNoOrderMessage];
                                                  }];
    
    [[LibraryAPI sharedInstance] fetchCurrentReturnOrder:^(NSArray *orders) {
        self.currentReturnOrders = orders;
        [self.tableView reloadData];
    }
                                                    fail:^(NSError *error) {
                                                        if (self.currentReturnOrders.count > 0) {
                                                            self.currentReturnOrders = @[];
                                                            [self.tableView reloadData];
                                                        }
                                                        
                                                        [self showNoOrderMessage];
                                                    }];
}

- (void)showNoOrderMessage {
//    if (self.currentReturnOrders.count == 0 && self.currentDropOrders.count == 0) {
//        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        [hud showMessage:@"Currently No Order"];
//    }
}

#pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    OrderDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"OrderDetailViewController"];
    OrderObject *orderObject = [self orderObjectAtIndexPath:indexPath];
    ClientObject *clientObject = [[LibraryAPI sharedInstance] clientObjectWithObjectID:orderObject.user_object_ID];
    [vc setOrder:orderObject client:clientObject];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return section?@"Return Vehicle Orders":@"Drop Vehicle Orders";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section?self.currentReturnOrders.count:self.currentDropOrders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderCellIdentifier
                                                      forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(OrderCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    // TODO set profile image
    OrderObject *orderObject = [self orderObjectAtIndexPath:indexPath];
    cell.profileImageView.layer.masksToBounds = YES;
    cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.height / 2;
    [[LibraryAPI sharedInstance] fetchClientObjectWithObjectID:orderObject.user_object_ID
                                                       success:^(ClientObject *clientObject) {
                                                           [[LibraryAPI sharedInstance] getPhotoWithURL:clientObject.profile_image_url
                                                                                                success:^(UIImage *image) {
                                                                                                    cell.profileImageView.image = image;
                                                                                                }
                                                                                                   fail:^(NSError *error) {
                                                                                                       
                                                                                                   }];
                                                           cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@", clientObject.last_name, clientObject.first_name];
                                                           if (orderObject.order_status == kUserOrderStatusUserDroppingOff) {
                                                               cell.infoLabel.text = [NSString stringWithFormat:@"Meet at %@", orderObject.drop_off_address];
                                                           } else if (orderObject.order_status == kUserOrderStatusParking){
                                                               cell.infoLabel.text = @"Valet is parking";
                                                           } else if (orderObject.order_status == kUserOrderStatusRequestingBack) {
                                                               cell.infoLabel.text = [NSString stringWithFormat:@"Return at %@", orderObject.return_address];
                                                           } else if (orderObject.order_status == kUserOrderStatusReturningBack) {
                                                               cell.infoLabel.text = @"Valet is returning";
                                                           }
                                                       }
                                                          fail:^(NSError *error) {
                                                              
                                                          }];
}

- (OrderObject *)orderObjectAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section?self.currentReturnOrders[indexPath.row]:self.currentDropOrders[indexPath.row];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count) {
        CLLocation *location = locations[0];
        NSLog(@"latitude:%f, longitude:%f", location.coordinate.latitude, location.coordinate.longitude);
        AVGeoPoint *geoPoint = [AVGeoPoint geoPointWithLocation:location];
        
        [[LibraryAPI sharedInstance] uploadValetLocation:geoPoint
                                              successful:^(ValetLocation *valetLocation) {
                                                  NSLog(@"location upload successfully");
                                              }
                                                    fail:^(NSError *error) {
                                                        NSLog(@"location upload fail");
                                                    }];
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
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:nil
                                                                  action:nil];
    [self.navigationItem setBackBarButtonItem:backButton];
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

- (NSArray *)currentDropOrders {
    if (!_currentDropOrders) {
        _currentDropOrders = [[NSArray alloc] init];
    }
    
    return _currentDropOrders;
}

- (NSArray *)currentReturnOrders {
    if (!_currentReturnOrders) {
        _currentReturnOrders = [[NSArray alloc] init];
    }
    
    return _currentReturnOrders;
}

- (NSTimer *)refreshOrderTimer {
    if (!_refreshOrderTimer) {
        _refreshOrderTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                              target:self
                                                            selector:@selector(getCurrentOrders)
                                                            userInfo:nil
                                                             repeats:YES];
    }
    
    return _refreshOrderTimer;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
