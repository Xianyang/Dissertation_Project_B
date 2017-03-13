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

#define DEFAULT_ZOOM_LEVEL                          15.5
#define SEARCH_TABLEVIEW_ORIGIN_Y                   140
#define SEARCH_TABLEVIEW_HEIGHT                     250
#define LEFT_TOP_CORNER_LATITUDE_HONG_KONG          22.514216
#define LEFT_TOP_CORNER_LONGITUDE_HONG_KONG         113.794132
#define RIGHT_BOTTOM_CORNER_LATITUDE_HONG_KONG      22.131892
#define RIGHT_BOTTOM_CORNER_LONGITUDE_HONG_KONG     114.392184

#define REQUEST_VALET_BTN_HEIGHT                    64
#define MAP_VALET_INFO_VIEW_HEIGHT                  257

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "InstructionViewController.h"
#import "ValetLocation.h"
#import "LibraryAPI.h"
#import "RequestValetButton.h"
#import "ValetMarker.h"
#import "MapFlag.h"
#import "MapValetInfoView.h"
#import "OrderObject.h"
#import "UserLocation.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";

@interface MainViewController () <UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, InstructionVCDelegate, MapFlagDelegate>
{
    BOOL _isSignInAnimated;
    BOOL _firstLocationUpdate;
    BOOL _isInPolygon;
    BOOL _isMapSetted;
    BOOL _isMyLocationBtnInOriginalPosition;
    BOOL _isGettingValetsLocations;
    
    UserOrderStatus _userOrderStatus;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (nonatomic, strong, nonnull) GMSGeocoder *geocoder;
@property (strong, nonatomic) NSArray * filterPlaces;

// the button in the bottom of the map
@property (strong, nonatomic) RequestValetButton *requestValetButton;

// the flag in the center of the map
@property (strong, nonatomic) MapFlag *mapFlag;

// the info view for valet
@property (strong, nonatomic) MapValetInfoView *mapValetInfoView;

// the timer for update valets' locations
@property (strong, nonatomic) NSTimer *valetLocationTimer;

// the array for valet markers
@property (strong, nonatomic) NSMutableArray *valetMarkers;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLocationUpdate = NO;
    _isMapSetted = NO;
    _isMyLocationBtnInOriginalPosition = YES;
    
    [self checkCurrentUser];
    [self setNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // TODO check user's order status
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch valets' location from server
    [self.valetLocationTimer setFireDate:[NSDate date]];
    
    if (!_isMapSetted && [AVUser currentUser]) {
        // check if user has an unfinished order
        [[LibraryAPI sharedInstance] checkIfUserHasUnfinishedOrder:^(OrderObject *orderObject) {
            // TODO show this order to user
            _userOrderStatus = orderObject.order_status;
        }
                                                           noOrder:^{
                                                               _userOrderStatus = kUserOrderStatusNone;
                                                               [self setMap];
                                                               _isMapSetted = YES;
                                                           }
                                                              fail:^{
                                                                  // TODO ask user to load view again
                                                              }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop fetch valets' location from server
    [self.valetLocationTimer setFireDate:[NSDate distantFuture]];
}

- (void)animateSignInView {
    _isSignInAnimated = YES;
}

#pragma mark - Google Map Delegate

- (void)setMap {
    // Listen to the myLocation property of GMSMapView.
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    self.mapView.delegate = self;
    
    // enable my location button
    self.mapView.settings.myLocationButton = YES;
    
    // Draw the polygon
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        polygon.map = self.mapView;
    }
    
    // add request service button
    [self.mapView addSubview:self.requestValetButton];
    
    // add the flag
    [self.mapView addSubview:self.mapFlag];
    
    // add the valet info view
    [self.mapView addSubview:self.mapValetInfoView];
    
    // ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
}

// get the user's location for the first time
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    // first location update means google map gets the user's location after launching the app
    if (!_firstLocationUpdate) {
        // 1. Jump to user's location
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:DEFAULT_ZOOM_LEVEL];
        
        // 2. Check if the user is in the polygon and add the flag
        if ([self checkIsPositionInPolygon:location.coordinate]) {
            _isInPolygon = YES;
            
            [self showRequestServiceView];
        } else {
            _isInPolygon = NO;
            
            [self hideRequestServiceView];
        }
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (_userOrderStatus == kUserOrderStatusNone) {
        if ([self checkIsPositionInPolygon:position.target]) {
            if (!_isInPolygon) {
                NSLog(@"user changes to polygon");
                _isInPolygon = YES;
                [self showRequestServiceView];
            }
        } else {
            if (_isInPolygon) {
                NSLog(@"user gets out of polygon");
                _isInPolygon = NO;
                [self hideRequestServiceView];
            }
        }
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

- (BOOL)checkIsPositionInPolygon:(CLLocationCoordinate2D)coordinate {
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        if (GMSGeometryContainsLocation(coordinate, polygon.path, YES)) {
            return YES;
        }
    }
    
    return NO;
}

- (void)showRequestServiceView {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // 0. show the view at the bottom
                         [self.requestValetButton showInMapView:self.mapView];
                         
                         // 1. change flag style
                         [self.mapFlag showWil];
                         
                         // 2. move my location button
                         [self moveMyLocationBtn:-self.requestValetButton.frame.size.height];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideRequestServiceView {
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // 0. hide the view at the bottom
                         [self.requestValetButton hideInMapView:self.mapView];
                         
                         // 1. change flag style
                         [self.mapFlag showGoToServiceArea];
                         
                         // 2. move my location button
                         [self moveMyLocationBtn:self.requestValetButton.frame.size.height];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)moveToServiceArea {
    NSLog(@"move to service area");
    [self.mapView animateToLocation:[[LibraryAPI sharedInstance] serviceLocation]];
    [self.mapView animateToZoom:DEFAULT_ZOOM_LEVEL];
}



- (void)moveMyLocationBtn:(CGFloat)margin {
    UIView *btnView = [self myLocationBtn];
    if (btnView) {
        CGRect frame = btnView.frame;
        
        if (margin < 0 && _isMyLocationBtnInOriginalPosition) {
            // move up
            _isMyLocationBtnInOriginalPosition = NO;
            frame.origin.y += margin;
        } else if (margin > 0 && !_isMyLocationBtnInOriginalPosition) {
            // move down
            _isMyLocationBtnInOriginalPosition = YES;
            frame.origin.y += margin;
        }
        
        btnView.frame = frame;
    }
}

- (UIView *)myLocationBtn {
    for (UIView *object in self.mapView.subviews) {
        if([[[object class] description] isEqualToString:@"GMSUISettingsPaddingView"] )
        {
            for(UIView *settingView in object.subviews) {
                if([[[settingView class] description] isEqualToString:@"GMSUISettingsView"] ) {
                    for(UIView *buttonView in settingView.subviews) {
                        if([[[buttonView class] description] isEqualToString:@"GMSx_QTMButton"] ) {
                            return buttonView;
                        }
                    }
                }
            }
            
        }
    }
    
    return nil;
}

- (void)backToMyPosition {
    [self.mapView animateToLocation:self.mapView.myLocation.coordinate];
}

#pragma mark - Request Valet

- (void)requestValetBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // 1. check if there is any valet
    if (![[LibraryAPI sharedInstance] valetLocations] || [[[LibraryAPI sharedInstance] valetLocations] count] == 0) {
        [hud showMessage:@"try later"];
        return;
    }
    
    // 2. find the nearest valet
    ValetLocation *nearestValetLocation = [[LibraryAPI sharedInstance] nearestValetLocation:self.mapView.camera.target];
    if (nearestValetLocation) {
        [nearestValetLocation fetchIfNeededInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (!error) {
                // 3. assign this valet to user
                
                // TODO create an order object
                [[LibraryAPI sharedInstance] createAnOrderWithValetObjectID:nearestValetLocation.objectId
                                                                parkAddress:[self.requestValetButton parkAddress]
                                                               parkLocation:[AVGeoPoint geoPointWithLatitude:self.mapView.camera.target.latitude
                                                                                                   longitude:self.mapView.camera.target.longitude]
                                                                    success:^(OrderObject *orderObject) {
                                                                        NSLog(@"meet your valet");
                                                                        [hud hideAnimated:YES];
                                                                        _userOrderStatus = kUserOrderStatusDroppingOff;
                                                                        
                                                                        [UIView animateWithDuration:0.2
                                                                                              delay:0
                                                                                            options:UIViewAnimationOptionCurveEaseIn
                                                                                         animations:^{
                                                                                             [self.mapValetInfoView showInMapView:self.mapView];
                                                                                             [self.requestValetButton hideInMapView:self.mapView];
                                                                                             [self.mapFlag hideInMapView:self.mapView];
                                                                                         }
                                                                                         completion:^(BOOL finished) {
                                                                                             
                                                                                         }];
                                                                    }
                                                                       fail:^(NSError *error) {
                                                                           [hud showMessage:@"try later"];
                                                                       }];
                
                // TODO set status of main view controller to ORDER
                // TODO show marker accroding to status
            } else {
                [hud showMessage:@"try later"];
            }
        }];
    } else {
        [hud showMessage:@"try later"];
        return;
    }
    
    NSLog(@"asdf");
}

#pragma mark - Valet Marker

- (void)fetchValetsLocation {
    NSLog(@"try to get valets' locations");
    if (!_isGettingValetsLocations) {
        _isGettingValetsLocations = YES;
        
        [[LibraryAPI sharedInstance] fetchValetsLocationsSuccessful:^(NSArray *array) {
            // add marker to the map
            [self moveValetMarkers:array];
        }
                                                               fail:^(NSError *error) {
                                                                   [self removeAllValetMarker];
                                                               }];
    }
}

- (void)moveValetMarkers:(NSArray *)valetLocations {
    // 0. check if there is any valets
    if (valetLocations.count == 0) {
        [self removeAllValetMarker];
        return;
    }
    
    // 1. set isUpdate of every marker to NO
    for (ValetMarker *valetMarker in self.valetMarkers) {
        valetMarker.isUpdate = NO;
    }
    
    // 2. set new locations
    for (ValetLocation *valetLocation in valetLocations) {
        ValetMarker *valetMarker = [self findValetMarker:valetLocation];
        
        if (valetMarker) {
            valetMarker.position = CLLocationCoordinate2DMake(valetLocation.valet_location.latitude, valetLocation.valet_location.longitude);
            valetMarker.isUpdate = YES;
        } else {
            ValetMarker *valetMarker = [[ValetMarker alloc] initWithValetObjectID:valetLocation.valet_object_ID AVGeoPoint:valetLocation.valet_location mapView:self.mapView];
            [self.valetMarkers addObject:valetMarker];
        }
    }
    
    // 3. remove marker that did not update
    NSMutableArray *tempCopy = [self.valetMarkers mutableCopy];
    for (ValetMarker *valetMarker in self.valetMarkers) {
        if (valetMarker.isUpdate == NO) {
            valetMarker.map = nil;
            [tempCopy removeObject:valetMarker];
        }
    }
    self.valetMarkers = tempCopy;
    
    // 4. finish
    _isGettingValetsLocations = NO;
}

- (ValetMarker *)findValetMarker:(ValetLocation *)valetLocation {
    for (ValetMarker *valetMarker in self.valetMarkers) {
        if ([valetMarker.valetObjectID isEqualToString:valetLocation.valet_object_ID]) {
            return valetMarker;
        }
    }
    
    return nil;
}

- (void)removeAllValetMarker {
    for (ValetMarker *valetMarker in self.valetMarkers) {
        valetMarker.map = nil;
    }
    
    [self.valetMarkers removeAllObjects];
    _isGettingValetsLocations = NO;
}

#pragma mark - InstructionVCDelegate

- (void)doneProcessInInstructionVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MapFlagDelegate

- (void)flagBtnClicked {
    [self moveToServiceArea];
}

# pragma mark - Search for a place

- (IBAction)launchSearch:(id)sender {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    acController.delegate = self;
    // set the search bounds to Hong Kong
    acController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(LEFT_TOP_CORNER_LATITUDE_HONG_KONG, LEFT_TOP_CORNER_LONGITUDE_HONG_KONG)
                                                                           coordinate:CLLocationCoordinate2DMake(RIGHT_BOTTOM_CORNER_LATITUDE_HONG_KONG, RIGHT_BOTTOM_CORNER_LONGITUDE_HONG_KONG)];
    [self presentViewController:acController animated:YES completion:nil];
}

// handle the user's selection
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self.mapView animateToLocation:place.coordinate];
    [self.mapView animateToZoom:DEFAULT_ZOOM_LEVEL];
//    self.mapView.camera = [GMSCameraPosition cameraWithTarget:place.coordinate zoom:DEFAULT_ZOOM_LEVEL];
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

#pragma mark - User 

- (void)checkCurrentUser {
    // if there is no user now, show the Instruction page
    if (![AVUser currentUser]) {
        UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InstructionNav"];
        InstructionViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        [self presentViewController:navVC animated:_isSignInAnimated completion:nil];
    }
}


#pragma mark - Some Settings

- (void)showHudWithMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud showMessage:message];
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

- (RequestValetButton *)requestValetButton {
    if (!_requestValetButton) {
        _requestValetButton = [[RequestValetButton alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, DEVICE_WIDTH, REQUEST_VALET_BTN_HEIGHT)];
        [_requestValetButton addTarget:self action:@selector(requestValetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _requestValetButton;
}

- (MapFlag *)mapFlag {
    if (!_mapFlag) {
        _mapFlag = [[MapFlag alloc] init];
        _mapFlag.delegate = self;
    }
    
    return _mapFlag;
}

- (MapValetInfoView *)mapValetInfoView {
    if (!_mapValetInfoView) {
        _mapValetInfoView = [[MapValetInfoView alloc] initWithFrame:CGRectMake(0, 0 - MAP_VALET_INFO_VIEW_HEIGHT, DEVICE_WIDTH, MAP_VALET_INFO_VIEW_HEIGHT)];
        _mapValetInfoView.backgroundColor = [UIColor whiteColor];
    }
    
    return _mapValetInfoView;
}

- (GMSGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [GMSGeocoder geocoder];
    }
    
    return _geocoder;
}

- (NSTimer *)valetLocationTimer {
    if (!_valetLocationTimer) {
        _valetLocationTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                               target:self
                                                             selector:@selector(fetchValetsLocation)
                                                             userInfo:nil
                                                              repeats:YES];
    }
    
    return _valetLocationTimer;
}

- (NSMutableArray *)valetMarkers {
    if (!_valetMarkers) {
        _valetMarkers = [[NSMutableArray alloc] init];
    }
    
    return _valetMarkers;
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
