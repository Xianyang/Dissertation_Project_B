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

#define SEARCH_TABLEVIEW_ORIGIN_Y                   140
#define SEARCH_TABLEVIEW_HEIGHT                     250
#define LEFT_TOP_CORNER_LATITUDE_HONG_KONG          22.514216
#define LEFT_TOP_CORNER_LONGITUDE_HONG_KONG         113.794132
#define RIGHT_BOTTOM_CORNER_LATITUDE_HONG_KONG      22.131892
#define RIGHT_BOTTOM_CORNER_LONGITUDE_HONG_KONG     114.392184

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>

#import "InstructionViewController.h"
#import "LibraryAPI.h"
#import "SearchResultCell.h"
#import "RequestValetPopup.h"
#import "RequestValetButton.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";

@interface MainViewController () <UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, InstructionVCDelegate>
{
    BOOL _firstLocationUpdate;
    BOOL _isInPolygon;
    
    BOOL _isAddObserverForMyLocation;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (strong, nonnull) GMSGeocoder *geocoder;

@property (strong, nonatomic) NSArray * filterPlaces;
@property (strong, nonatomic) RequestValetButton *requestValetButton;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLocationUpdate = NO;
    _isAddObserverForMyLocation = NO;
    
    if (![AVUser currentUser]) {
    
        UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InstructionNav"];
        InstructionViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        [self presentViewController:navVC animated:NO completion:nil];
    }
    
    [self setNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setMap];
}

//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    
//    [self.mapView removeObserver:self
//                      forKeyPath:@"myLocation"
//                         context:NULL];
//}

#pragma mark - InstructionVCDelegate

- (void)doneProcessInInstructionVC {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    self.geocoder = [GMSGeocoder geocoder];
    
    // Listen to the myLocation property of GMSMapView.
    if (!_isAddObserverForMyLocation) {
        [self.mapView addObserver:self
                       forKeyPath:@"myLocation"
                          options:NSKeyValueObservingOptionNew
                          context:NULL];
        
        _isAddObserverForMyLocation = YES;
    }
    
    self.mapView.delegate = self;
    _isInPolygon = NO;
    
    // add request service button
    [self.mapView addSubview:self.requestValetButton];
    
    // enable my location button
    self.mapView.settings.myLocationButton = YES;
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    // first location update means google map gets the user's location after launching the app
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:16.5];
        
        // add the drop off flag
        CGFloat flagSize = 50;
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"drop_off_flag"]];
        imageView.frame = CGRectMake(self.mapView.frame.size.width / 2 - flagSize / 2, self.mapView.frame.size.height / 2 - flagSize, flagSize, flagSize);
        [self.mapView addSubview:imageView];
        
        // *** Draw the polygon ***
        for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
            polygon.map = self.mapView;
        }
        
        // TODO check if the position is in the service area
//        [self popUpRequestValet];
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    // check if the position is within polygons
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        if (GMSGeometryContainsLocation(position.target, polygon.path, YES)) {
            if (!_isInPolygon) {
                // change to service area
                NSLog(@"YES: you are in %@.", polygon.title);
                
                _isInPolygon = YES;
                
                // pop up request service button
                [UIView animateWithDuration:0.1
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseIn
                                 animations:^{
                                     self.requestValetButton.frame = CGRectMake(0, self.mapView.frame.size.height - self.requestValetButton.frame.size.height,
                                                                                self.requestValetButton.frame.size.width, self.requestValetButton.frame.size.height);
                                 }
                                 completion:^(BOOL finished) {
                                     
                                 }];
                
                // TODO change the flag to valet
                
            }
            
            return;
        }
    }
    
    if (_isInPolygon) {
        // get out of service area
        NSLog(@"get out of polygon");
        
        _isInPolygon = NO;
        
        // hide the request service button
        [UIView animateWithDuration:0.2
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.requestValetButton.frame = CGRectMake(0, self.mapView.frame.size.height,
                                                                        self.requestValetButton.frame.size.width, self.requestValetButton.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
        
        // TODO change the flag to "go to service area"
    }
    
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (_isInPolygon) {
        // update the postion of target
        [self.geocoder reverseGeocodeCoordinate:position.target
                              completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
                                  [self.requestValetButton setLocation:response.results[0].lines[0]];
                              }];
    }
}

- (void)popUpRequestValet {
    RequestValetPopup *rvPopup = [[RequestValetPopup alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height - 128, self.mapView.frame.size.width, 128)];
    rvPopup.backgroundColor = [UIColor redColor];
    [self.mapView addSubview:rvPopup];
}

- (void)backToMyPosition {
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
}

# pragma mark - Search for a place

- (IBAction)launchSearch:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    acController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(LEFT_TOP_CORNER_LATITUDE_HONG_KONG, LEFT_TOP_CORNER_LONGITUDE_HONG_KONG)
                                                                           coordinate:CLLocationCoordinate2DMake(RIGHT_BOTTOM_CORNER_LATITUDE_HONG_KONG, RIGHT_BOTTOM_CORNER_LONGITUDE_HONG_KONG)];
    [self presentViewController:acController animated:YES completion:nil];
}

// handle the user's selection
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.mapView animateToLocation:place.coordinate];
    [self.mapView animateToZoom:16.5];
//    self.mapView.camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:16.5];
}

- (void)viewController:(GMSAutocompleteViewController *)viewController didFailAutocompleteWithError:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
    // TODO: handle the error.
    NSLog(@"Error: %@", [error description]);
}

// User canceled the operation.
- (void)wasCancelled:(GMSAutocompleteViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Turn the network activity indicator on and off again.
- (void)didRequestAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didUpdateAutocompletePredictions:(GMSAutocompleteViewController *)viewController {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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

- (RequestValetButton *)requestValetButton {
    if (!_requestValetButton) {
        _requestValetButton = [[RequestValetButton alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, DEVICE_WIDTH, 64.0f)];
    }
    
    return _requestValetButton;
}

//- (GMSGeocoder *)geocoder {
//    if (!_geocoder) {
//        _geocoder = [GMSGeocoder geocoder];
//    }
//    
//    return _geocoder;
//}

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
