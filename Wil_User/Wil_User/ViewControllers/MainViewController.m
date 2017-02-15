//
//  MainViewController.m
//  Wil_User
//
//  Created by xianyang on 20/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

// ----- Key for Google Map & Google Places -----
// AIzaSyBGDLcY7VysgsEzK0QZnx7DOFBbJhkKsIo
// AIzaSyC-f-MbvinrjO8ZtxLqpFkhbQDONbvuOe0
// ----------------------------------------------

#define SEARCH_TABLEVIEW_ORIGIN_Y 140
#define SEARCH_TABLEVIEW_HEIGHT 200

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *searchFieldBackground;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (strong, nonatomic) NSMutableArray * filterPlaces;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self setSearchField];
    
    [self setMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)setMap {
    // Create a GMSCameraPosition that tells the map to display the
    // coordinate -33.86,151.20 at zoom level 6.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86
                                                            longitude:151.20
                                                                 zoom:6];
    self.mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.mapView.myLocationEnabled = YES;
    
    // Creates a marker in the center of the map.
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(-33.86, 151.20);
    marker.title = @"Sydney";
    marker.snippet = @"Australia";
    marker.map = self.mapView;
}

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

- (void)setSearchField {
    // 1. set a round corner
    self.searchFieldBackground.layer.cornerRadius = 5;
    self.searchFieldBackground.layer.masksToBounds = YES;
    
    // 2. hide the table view
    self.searchResultTableView.frame = CGRectMake(10.0f, DEVICE_HEIGHT, DEVICE_WIDTH - 20.0f, 200.0f);
    
    // 3. set delegate
    self.searchResultTableView.delegate = self;
    self.searchResultTableView.dataSource = self;
    self.searchTextField.delegate = self;
}

# pragma mark - Search Field

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([textField isEqual:self.searchTextField]) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.searchResultTableView.frame = CGRectMake(10.0f, SEARCH_TABLEVIEW_ORIGIN_Y,
                                                                           DEVICE_WIDTH - 20.0f, SEARCH_TABLEVIEW_HEIGHT);
                             self.maskView.hidden = NO;
                             self.rightBarButton.image = nil;
                             self.rightBarButton.title = @"cancel";
                             self.rightBarButton.target = self;
                             self.rightBarButton.action = @selector(cancelSearch);
                         }];
    }
}

- (void)cancelSearch {
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.searchResultTableView.frame = CGRectMake(10.0f, DEVICE_HEIGHT,
                                                                       DEVICE_WIDTH - 20.0f, SEARCH_TABLEVIEW_HEIGHT);
                         [self.searchTextField resignFirstResponder];
                         self.maskView.hidden = YES;
                         self.rightBarButton.image = [UIImage imageNamed:@"navigation"];
                         self.rightBarButton.title = @"";
                         self.rightBarButton.action = nil;
                     }];
}

# pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
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
