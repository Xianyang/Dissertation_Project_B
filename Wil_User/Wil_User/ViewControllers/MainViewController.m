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
#define FLAG_RECT1_WIDTH                            70
#define FLAG_RECT2_WIDTH                            130
#define FLAG_RECT_HEIGHT                            35

#import "MainViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import <GooglePlaces/GooglePlaces.h>
#import "InstructionViewController.h"
#import "ValetLocation.h"
#import "LibraryAPI.h"
#import "RequestValetButton.h"
#import "ValetMarker.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";

@interface MainViewController () <UITextFieldDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, InstructionVCDelegate>
{
    BOOL _isSignInAnimated;
    BOOL _firstLocationUpdate;
    BOOL _isInPolygon;
    BOOL _isMapSetted;
    BOOL _isMyLocationBtnInOriginalPosition;
    BOOL _isGettingValetsLocations;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) UIImageView *flagImageView;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (nonatomic, strong, nonnull) GMSGeocoder *geocoder;

@property (strong, nonatomic) NSArray * filterPlaces;
@property (strong, nonatomic) RequestValetButton *requestValetButton;

// the flag in the center of the map
@property (strong, nonatomic) UIView *flagRect;
@property (strong, nonatomic) UIView *flagLine;
@property (strong, nonatomic) UITextField *flagTextField;
@property (strong, nonatomic) UIButton *flagBtn;

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch valets' location from server
    [self.valetLocationTimer setFireDate:[NSDate date]];
    
    if (!_isMapSetted) {
        [self setMap];
        _isMapSetted = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.valetLocationTimer setFireDate:[NSDate distantFuture]];
}

- (void)animateSignInView {
    _isSignInAnimated = YES;
}

#pragma mark - InstructionVCDelegate

- (void)doneProcessInInstructionVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Google Map

- (void)setMap {
    // Listen to the myLocation property of GMSMapView.
    [self.mapView addObserver:self
                   forKeyPath:@"myLocation"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
    
    self.mapView.delegate = self;
    
    // add request service button
    [self.mapView addSubview:self.requestValetButton];
    
    // enable my location button
    self.mapView.settings.myLocationButton = YES;
    
    // Draw the polygon
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        polygon.map = self.mapView;
    }
    
    // add the flag
    self.flagRect.frame = CGRectMake(142, -70, 130, 35);
    self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                     self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                     2, 35);
    self.flagTextField.frame = self.flagRect.frame;
    self.flagBtn.frame = self.flagRect.frame;
    [self.mapView addSubview:self.flagRect];
    [self.mapView addSubview:self.flagLine];
    [self.mapView addSubview:self.flagTextField];
    [self.mapView addSubview:self.flagBtn];
    
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
                         self.requestValetButton.frame = CGRectMake(0, self.mapView.frame.size.height - self.requestValetButton.frame.size.height,
                                                                    self.requestValetButton.frame.size.width, self.requestValetButton.frame.size.height);
                         
                         // 1. change the rect
                         self.flagRect.frame = CGRectMake((DEVICE_WIDTH - FLAG_RECT1_WIDTH) / 2, (DEVICE_HEIGHT - 64) / 2 - FLAG_RECT_HEIGHT * 2,
                                                          FLAG_RECT1_WIDTH, FLAG_RECT_HEIGHT);
                         self.flagRect.backgroundColor = [UIColor blackColor];
                         
                         // 2. change the line
                         self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                                          self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                                          2, FLAG_RECT_HEIGHT);
                         self.flagLine.backgroundColor = self.flagRect.backgroundColor;
                         
                         // 3. change the text
                         self.flagTextField.frame = self.flagRect.frame;
                         self.flagTextField.text = @"WIL";
                         self.flagTextField.font = [UIFont systemFontOfSize:15.0f];
                         
                         // 4. remove flag button's target
                         self.flagBtn.frame = self.flagRect.frame;
                         [self.flagBtn removeTarget:self action:@selector(moveToServiceArea) forControlEvents:UIControlEventTouchUpInside];
                         
                         // 5. move my location button
                         [self moveMyLocationBtn:-64];
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
                         self.requestValetButton.frame = CGRectMake(0, self.mapView.frame.size.height,
                                                                    self.requestValetButton.frame.size.width, self.requestValetButton.frame.size.height);
                         
                         // 1. change the rect
                         self.flagRect.frame = CGRectMake((DEVICE_WIDTH - FLAG_RECT2_WIDTH) / 2, (DEVICE_HEIGHT - 64) / 2 - FLAG_RECT_HEIGHT * 2,
                                                          FLAG_RECT2_WIDTH, FLAG_RECT_HEIGHT);
                         self.flagRect.backgroundColor = [[LibraryAPI sharedInstance] themeBlueColor];
                         
                         // 2. change the line color
                         self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                                          self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                                          2, FLAG_RECT_HEIGHT);
                         self.flagLine.backgroundColor = self.flagRect.backgroundColor;
                         
                         // 3. change the text
                         self.flagTextField.frame = self.flagRect.frame;
                         self.flagTextField.text = @"Go To Service Area";
                         self.flagTextField.font = [UIFont systemFontOfSize:13.0f];
                         
                         // 4. add flag button's target
                         self.flagBtn.frame = self.flagRect.frame;
                         [self.flagBtn addTarget:self action:@selector(moveToServiceArea) forControlEvents:UIControlEventTouchUpInside];
                         
                         // 4. move my location button
                         [self moveMyLocationBtn:64];
                         
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
        _requestValetButton = [[RequestValetButton alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, DEVICE_WIDTH, 64.0f)];
        [_requestValetButton addTarget:self action:@selector(requestValetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _requestValetButton;
}

- (UIView *)flagRect {
    if (!_flagRect) {
        _flagRect = [[UIView alloc] init];
        _flagRect.layer.masksToBounds = YES;
        _flagRect.layer.cornerRadius = 5;
    }
    
    return _flagRect;
}

- (UIView *)flagLine {
    if (!_flagLine) {
        _flagLine = [[UIView alloc] init];
    }
    
    return _flagLine;
}

- (UITextField *)flagTextField {
    if (!_flagTextField) {
        _flagTextField = [[UITextField alloc] init];
        _flagTextField.textColor = [UIColor whiteColor];
        _flagTextField.textAlignment = NSTextAlignmentCenter;
    }
    
    return _flagTextField;
}

- (UIButton *)flagBtn {
    if (!_flagBtn) {
        _flagBtn = [[UIButton alloc] init];
    }
    
    return _flagBtn;
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
