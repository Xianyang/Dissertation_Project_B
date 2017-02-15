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
#define SEARCH_TABLEVIEW_HEIGHT 250

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

#import "SearchResultCell.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    BOOL _firstLocationUpdate;
}
@property (weak, nonatomic) IBOutlet UIView *searchFieldBackground;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *searchResultTableView;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightBarButton;

@property (strong, nonatomic) NSArray * filterPlaces;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLocationUpdate = NO;
    
    [self setNavigationBar];
    [self setSearchField];
    
    [self setMap];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Google Map

- (void)setMap {
    /*
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
     */
    
    // Listen to the myLocation property of GMSMapView.
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
     if (!_firstLocationUpdate) {
         // If the first location update has not yet been recieved, then jump to that location.
         _firstLocationUpdate = YES;
         CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
         self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:14];
     }
}

- (void)backToMyPosition {
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
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

- (void)textFieldDidChange:(UITextField *)textField {
    if ([textField isEqual:self.searchTextField]) {
        GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
        filter.type = kGMSPlacesAutocompleteTypeFilterEstablishment;
        
        // set the bound for hong kong
        GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(22.514216, 113.794132)
                                                                           coordinate:CLLocationCoordinate2DMake(22.131892, 114.392184)];
        
        [self.placesClient autocompleteQuery:textField.text
                                      bounds:bounds
                                      filter:filter
                                    callback:^(NSArray *results, NSError *error) {
                                        if (error != nil) {
                                            NSLog(@"Autocomplete error %@", [error localizedDescription]);
                                            return;
                                        }
                                        
                                        for (GMSAutocompletePrediction* result in results) {
                                            NSLog(@"Result '%@' with placeID %@", result.attributedFullText.string, result.placeID);
                                        }
                                        
                                        self.filterPlaces = results;
                                        [self.searchResultTableView reloadData];
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
                         self.rightBarButton.action = @selector(backToMyPosition);
                     }];
}

# pragma mark - UITableView

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filterPlaces.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SearchResultCell *cell = [tableView dequeueReusableCellWithIdentifier:SearchResultCellIdentifier];
    
    GMSAutocompletePrediction *result = self.filterPlaces[indexPath.row];
    cell.textLabel.text = result.attributedFullText.string;
    
    return cell;
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
    
    self.rightBarButton.target = self;
    self.rightBarButton.action = @selector(backToMyPosition);
    
    //    UIBarButtonItem *backButton =
    //    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
    //                                     style:UIBarButtonItemStylePlain
    //                                    target:nil
    //                                    action:nil];
    //    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void)setSearchField {
    // 1. set the text field
    [self.searchTextField addTarget:self
                             action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    self.searchFieldBackground.layer.cornerRadius = 5;
    self.searchFieldBackground.layer.masksToBounds = YES;
    
    // 2. set the table view
    self.searchResultTableView.frame = CGRectMake(10.0f, DEVICE_HEIGHT, DEVICE_WIDTH - 20.0f, 200.0f);
    self.searchResultTableView.layer.cornerRadius = 5;
    self.searchResultTableView.layer.masksToBounds = YES;
    
    // 3. set delegate
    self.searchResultTableView.delegate = self;
    self.searchResultTableView.dataSource = self;
    self.searchTextField.delegate = self;
}

- (GMSPlacesClient *)placesClient {
    if (!_placesClient) {
        _placesClient = [[GMSPlacesClient alloc] init];
    }
    
    return _placesClient;
}

- (NSArray *)filterPlaces {
    if (!_filterPlaces) {
        _filterPlaces = [[NSArray alloc] init];
    }
    
    return _filterPlaces;
}

- (void)dealloc {
    [self.mapView removeObserver:self
                      forKeyPath:@"myLocation"
                         context:NULL];
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
