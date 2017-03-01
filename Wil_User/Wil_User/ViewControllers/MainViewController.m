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
#define FLAG_SIZE                                   60

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
    BOOL _isSignInAnimated;
    BOOL _firstLocationUpdate;
    BOOL _isInPolygon;
    BOOL _isMapSetted;
    BOOL _isMyLocationBtnInOriginalPosition;
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
    
    if (!_isMapSetted) {
        [self setMap];
        _isMapSetted = YES;
    }
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
    [self.mapView addSubview:self.flagRect];
    [self.mapView addSubview:self.flagLine];
    [self.mapView addSubview:self.flagTextField];
    
    // Ask for My Location data after the map has already been added to the UI.
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
        self.mapView.camera = [GMSCameraPosition cameraWithTarget:location.coordinate zoom:16.5];
        
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
                         self.flagRect.frame = CGRectMake(172, 266, 70, 35);
                         self.flagRect.backgroundColor = [UIColor blackColor];
                         
                         // 2. change the line
                         self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                                          self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                                          2, 35);
                         self.flagLine.backgroundColor = self.flagRect.backgroundColor;
                         
                         // 3. change the text
                         self.flagTextField.frame = self.flagRect.frame;
                         self.flagTextField.text = @"WIL";
                         self.flagTextField.font = [UIFont systemFontOfSize:15.0f];
                         
                         // 4. move my location button
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
                         self.flagRect.frame = CGRectMake(142, 266, 130, 35);
                         self.flagRect.backgroundColor = [UIColor colorWithRed:76.0f / 255.0f green:124.0f / 255.0f blue:194.0f / 255.0f alpha:1.0f];
                         
                         // 2. change the line color
                         self.flagLine.frame = CGRectMake(self.flagRect.frame.origin.x + self.flagRect.frame.size.width / 2,
                                                          self.flagRect.frame.origin.y + self.flagRect.frame.size.height,
                                                          2, 35);
                         self.flagLine.backgroundColor = self.flagRect.backgroundColor;
                         
                         // 3. change the text
                         self.flagTextField.frame = self.flagRect.frame;
                         self.flagTextField.text = @"Go To Service Area";
                         self.flagTextField.font = [UIFont systemFontOfSize:13.0f];
                         
                         // 4. move my location button
                         [self moveMyLocationBtn:64];
                         
                     }
                     completion:^(BOOL finished) {
                         
                     }];
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

- (GMSGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [GMSGeocoder geocoder];
    }
    
    return _geocoder;
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
