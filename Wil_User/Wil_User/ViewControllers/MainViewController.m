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

#define MAP_SEARCH_PLACE_VIEW_HEIGHT                50

#define MAP_VALET_INFO_VIEW_HEIGHT                  100

#define MAP_PARK_INFO_VIEW_ORIGIN_Y                 70
#define MAP_PARK_INFO_VIEW_HEIGHT                   100

#define MAP_PAYMENT_INFO_VIEW_HEIGHT                64
#define REQUEST_VALET_BTN_HEIGHT                    64

@import PassKit;
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
#import "MapSearchPlaceView.h"
#import "MapParkInfoView.h"
#import "MapPaymentView.h"
#import "OrderObject.h"
#import "ClientLocation.h"

static NSString * const SearchResultCellIdentifier = @"SearchResultCell";

@interface MainViewController () <UITextFieldDelegate, CLLocationManagerDelegate, GMSAutocompleteViewControllerDelegate, GMSMapViewDelegate, InstructionVCDelegate, MapFlagDelegate, MapValetInfoViewDelegate, MapSearchPlaceViewDelegate, MapPaymentViewDelegate, PKPaymentAuthorizationViewControllerDelegate>
{
    BOOL _isSignInAnimated;
    BOOL _firstLocationUpdate;
    BOOL _isInPolygon;
    BOOL _isMapSetted;
    BOOL _isMyLocationBtnInOriginalPosition;
    BOOL _isGettingValetsLocations;
    BOOL _isNeedUpdateBounds;
    
    UserOrderStatus _userOrderStatus;
    
    CGRect _myLocationBtnFrame;
}
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *maskView;
@property (strong, nonatomic) UIBarButtonItem *navRightItem;
@property (strong, nonatomic) GMSPlacesClient *placesClient;
@property (nonatomic, strong, nonnull) GMSGeocoder *geocoder;
@property (strong, nonatomic) NSArray * filterPlaces;
@property (strong, nonatomic) CLLocationManager *locationManager;

// the button in the bottom of the map
@property (strong, nonatomic) RequestValetButton *requestValetButton;

// the flag in the center of the map
@property (strong, nonatomic) MapFlag *wilFlag;

// the info view for valet
@property (strong, nonatomic) MapValetInfoView *mapValetInfoView;

// the search field
@property (strong, nonatomic) MapSearchPlaceView *mapSearchPlaceView;

// show parking info
@property (strong, nonatomic) MapParkInfoView *mapParkInfoView;

// show payment info
@property (strong, nonatomic) MapPaymentView *mapPaymentView;

// the timer for updating valets' locations
@property (strong, nonatomic) NSTimer *valetLocationTimer;

// the timer for updating order status
@property (strong, nonatomic) NSTimer *orderStatusTimer;

// the array for valet markers
@property (strong, nonatomic) NSMutableArray *valetMarkers;

// the order object
@property (strong, nonatomic) OrderObject *orderObject;

// the flag marker to show drop off or return back point
@property (strong, nonatomic) GMSMarker *flagMarker;

// the vehicle marker to show the position of vehicle
@property (strong, nonatomic) GMSMarker *vehicleMarker;

// the route
@property (strong, nonatomic) GMSPolyline *route;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _firstLocationUpdate = NO;
    _isMapSetted = NO;
    _isMyLocationBtnInOriginalPosition = YES;
    _userOrderStatus = kUserOrderStatusUndefine;
    [[LibraryAPI sharedInstance] saveClientLocationObjectIDLocally:@""];
    
    [self checkCurrentUser];
    [self setNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // open all timers
    [self.valetLocationTimer setFireDate:[NSDate date]];
    [self.orderStatusTimer setFireDate:[NSDate date]];
    
    [self fetchValetsLocation];
    [self checkIfUserHasUnfinishedOrder];
    
    if (!_isMapSetted) {
        [self setMap];
        _isMapSetted = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // stop all timers
    [self.valetLocationTimer setFireDate:[NSDate distantFuture]];
    [self.orderStatusTimer setFireDate:[NSDate distantFuture]];
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
    _myLocationBtnFrame = [[self myLocationBtn] frame];
    
    // enable traffic
    self.mapView.trafficEnabled = YES;
    
    // set max and min zoom level
    [self.mapView setMinZoom:12 maxZoom:18];
    
    // Draw the polygon
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        polygon.map = self.mapView;
    }
    
    // add search view
    [self.mapView addSubview:self.mapSearchPlaceView];
    
    // add request service button
    [self.mapView addSubview:self.requestValetButton];
    
    // add the flag
    [self.mapView addSubview:self.wilFlag];
    
    // add the valet info view
    [self.mapView addSubview:self.mapValetInfoView];
    
    // add the park info view
    [self.mapView addSubview:self.mapParkInfoView];
    
    // add the payment info view
    [self.mapView addSubview:self.mapPaymentView];
    
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
//        if (_userOrderStatus == kUserOrderStatusNone) {
//            [self setMapToUserOrderStatusNone:location.coordinate];
//        }
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {
    if (_userOrderStatus == kUserOrderStatusNone || _userOrderStatus == kUserOrderStatusParked || _userOrderStatus == kUserOrderStatusUndefine) {
        [self updateRequestServiceView:position.target];
    }
}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    [self.geocoder reverseGeocodeCoordinate:position.target
                          completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
                              [self.mapSearchPlaceView setParkAddress:response.results[0].lines[0]];
                          }];
}

- (void)fitBounds {
    NSMutableArray *markers = [NSMutableArray arrayWithObjects:self.flagMarker, self.vehicleMarker, nil];
    [markers addObjectsFromArray:self.valetMarkers];
    
    if (markers.count == 2) return;
    if (!_isNeedUpdateBounds) return;
    
    _isNeedUpdateBounds = NO;
    
    CLLocationCoordinate2D firstPos = self.mapView.myLocation.coordinate;
    GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithCoordinate:firstPos coordinate:firstPos];
    for (GMSMarker *marker in markers) {
        if (marker.map) {
            bounds = [bounds includingCoordinate:marker.position];
        }
    }
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    
    [self.mapView animateWithCameraUpdate:update];
}

#pragma mark - Order Status

- (void)fetchOrderStatus {
    // check order again to see if there is any change
    if (self.orderObject.order_status == kUserOrderStatusUserDroppingOff ||
        self.orderObject.order_status == kUserOrderStatusParking ||
        self.orderObject.order_status == kUserOrderStatusRequestingBack ||
        self.orderObject.order_status == kUserOrderStatusReturningBack) {
        if (self.orderObject) {
            [[LibraryAPI sharedInstance] fetchOrderStatusWithObjectID:self.orderObject.objectId
                                                              success:^(OrderObject *orderObject) {
                                                                  if (self.orderObject.order_status != orderObject.order_status) {
                                                                      self.orderObject = orderObject;
                                                                      [self updateMapViewStatus];
                                                                  }
                                                              }
                                                                 fail:^(NSError *error) {
                                                                     
                                                                 }];
        }
    }
}

- (void)checkIfUserHasUnfinishedOrder {
    if ([AVUser currentUser] && !self.orderObject) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        // check if user has an unfinished order
        [[LibraryAPI sharedInstance] checkIfUserHasUnfinishedOrder:^(OrderObject *orderObject) {
            self.orderObject = orderObject;
            
            [hud hideAnimated:YES];
            [self updateMapViewStatus];
        }
                                                           noOrder:^{
                                                               [hud hideAnimated:YES];
                                                               [self setMapToUserOrderStatusNone:self.mapView.camera.target];
                                                           }
                                                              fail:^{
                                                                  // TODO ask user to load view again
                                                                  [hud showMessage:@"error, try again"];
                                                                  NSLog(@"error");
                                                              }];
    }
}

- (void)updateMapViewStatus {
    if (self.orderObject.order_status == kUserOrderStatusUserDroppingOff) {
        [self setMapToUserOrderStatusUserDroppingOff];
    } else if (self.orderObject.order_status == kUserOrderStatusParking) {
        [self setMapToUserOrderStatusParking];
    } else if (self.orderObject.order_status == kUserOrderStatusParked ) {
        // TODO notificate client
        [self setMapToUserOrderStatusParked];
    } else if (self.orderObject.order_status == kUserOrderStatusRequestingBack) {
        [self setMapToUserOrderStatusRequestingBack];
    } else if (self.orderObject.order_status == kUserOrderStatusReturningBack) {
        [self setMapToUserOrderStatusReturningBack];
    } else if (self.orderObject.order_status == kUserOrderStatusPaymentPending) {
        [self setMapToUserOrderStatusPaymentPending];
    } else if (self.orderObject.order_status == kUserOrderStatusFinished) {
        [self setMapToUserOrderStatusFinished];
    }
}

// kUserOrderStatusNone
- (void)setMapToUserOrderStatusNone:(CLLocationCoordinate2D)coordinate {
    // 1. set status
    _userOrderStatus = kUserOrderStatusNone;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    self.flagMarker.map = nil;
    self.vehicleMarker.map = nil;
    
    // 4. remove the route
    self.route.map = nil;
    
    // 5. update the view
    [self updateRequestServiceView:coordinate];
    
    // 6. update the address
    [self mapView:self.mapView idleAtCameraPosition:self.mapView.camera];
}

- (void)setMapToUserOrderStatusUserDroppingOff {
    // 1. set status
    _userOrderStatus = kUserOrderStatusUserDroppingOff;
    
    // 2. set right navigation item to cancel
    self.navRightItem = [[UIBarButtonItem alloc] initWithTitle:@"cancel" style:UIBarButtonItemStylePlain
                                                        target:self action:@selector(tryCancelOrder)];
    self.navigationItem.rightBarButtonItem = self.navRightItem;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    _isNeedUpdateBounds = YES;
    
    self.flagMarker.map = self.mapView;
    self.flagMarker.position = CLLocationCoordinate2DMake(self.orderObject.park_location.latitude, self.orderObject.park_location.longitude);
    
    self.vehicleMarker.map = nil;
    
    // 4. add the route from my position to park address
    [[LibraryAPI sharedInstance] getRouteWithMyLocation:self.mapView.myLocation
                                    destinationLocation:[self.orderObject.park_location locationWithGeoPoint:self.orderObject.park_location]
                                                success:^(GMSPolyline *route) {
                                                    self.route = route;
                                                    self.route.map = self.mapView;
                                                }
                                                   fail:^(NSError *error) {
                                                       
                                                   }];
    
    // 5. update the view
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         // 5.1 show map info view
                         [self.mapValetInfoView show];
                         [self.mapValetInfoView setValetInfo:self.orderObject.drop_valet_object_ID address:self.orderObject.park_address orderStatus:_userOrderStatus];
                         
                         // 5.2 hide other views
                         [self.mapSearchPlaceView hide];
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag hideInMapView:self.mapView];
                         [self.mapParkInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
                         
                         _isMyLocationBtnInOriginalPosition = YES;
                         [[self myLocationBtn] setFrame:_myLocationBtnFrame];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setMapToUserOrderStatusParking {
    // 1. set status
    _userOrderStatus = kUserOrderStatusParking;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    _isNeedUpdateBounds = YES;
    
    self.flagMarker.map = self.mapView;
    self.flagMarker.position = CLLocationCoordinate2DMake(self.orderObject.park_location.latitude, self.orderObject.park_location.longitude);
    
    self.vehicleMarker.map = nil;
    
    // 4. remove the route
    self.route.map = nil;
    
    // 5. update the view
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.mapValetInfoView show];
                         [self.mapValetInfoView setValetInfo:self.orderObject.drop_valet_object_ID address:self.orderObject.park_address orderStatus:_userOrderStatus];
                         
                         [self.mapSearchPlaceView hide];
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag hideInMapView:self.mapView];
                         [self.mapParkInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
                         
                         _isMyLocationBtnInOriginalPosition = YES;
                         [[self myLocationBtn] setFrame:_myLocationBtnFrame];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setMapToUserOrderStatusParked {
    // 1. set status
    _userOrderStatus = kUserOrderStatusParked;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    _isNeedUpdateBounds = YES;

    self.flagMarker.map = nil;
    
    self.vehicleMarker.map = self.mapView;
    self.vehicleMarker.position = CLLocationCoordinate2DMake(self.orderObject.parked_location.latitude, self.orderObject.parked_location.longitude);
    
    // 4. remove the route
    self.route.map = nil;
    
    // 5. update the view
    [self updateRequestServiceView:self.mapView.camera.target];
    
    // 6. update the address
    [self mapView:self.mapView idleAtCameraPosition:self.mapView.camera];
}

- (void)setMapToUserOrderStatusRequestingBack {
    // 1. set status
    _userOrderStatus = kUserOrderStatusRequestingBack;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    _isNeedUpdateBounds = YES;
    
    self.flagMarker.map = self.mapView;
    self.flagMarker.position = CLLocationCoordinate2DMake(self.orderObject.return_location.latitude, self.orderObject.return_location.longitude);
    
    self.vehicleMarker.map = self.mapView;
    self.vehicleMarker.position = CLLocationCoordinate2DMake(self.orderObject.parked_location.latitude, self.orderObject.parked_location.longitude);
    
    // 4. add the route
    [[LibraryAPI sharedInstance] getRouteWithMyLocation:self.mapView.myLocation
                                    destinationLocation:[self.orderObject.return_location locationWithGeoPoint:self.orderObject.return_location]
                                                success:^(GMSPolyline *route) {
                                                    self.route = route;
                                                    self.route.map = self.mapView;
                                                }
                                                   fail:^(NSError *error) {
                                                       
                                                   }];
    
    // 5. update the view
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.mapValetInfoView show];
                         [self.mapValetInfoView setValetInfo:self.orderObject.return_valet_object_ID address:self.orderObject.return_address orderStatus:_userOrderStatus];
                         
                         [self.mapSearchPlaceView hide];
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag hideInMapView:self.mapView];
                         [self.mapParkInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
                         
                         _isMyLocationBtnInOriginalPosition = YES;
                         [[self myLocationBtn] setFrame:_myLocationBtnFrame];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setMapToUserOrderStatusReturningBack {
    // 1. set status
    _userOrderStatus = kUserOrderStatusReturningBack;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self fetchValetsLocation];
    _isNeedUpdateBounds = YES;
    
    self.flagMarker.map = self.mapView;
    self.flagMarker.position = CLLocationCoordinate2DMake(self.orderObject.return_location.latitude, self.orderObject.return_location.longitude);
    
    self.vehicleMarker.map = nil;
    
    // 4. add the route
    if (!self.route.map) {
        [[LibraryAPI sharedInstance] getRouteWithMyLocation:self.mapView.myLocation
                                        destinationLocation:[self.orderObject.return_location locationWithGeoPoint:self.orderObject.return_location]
                                                    success:^(GMSPolyline *route) {
                                                        self.route = route;
                                                        self.route.map = self.mapView;
                                                    }
                                                       fail:^(NSError *error) {
                                                           
                                                       }];
    }
    
    // 5. update the view
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.mapValetInfoView show];
                         [self.mapValetInfoView setValetInfo:self.orderObject.return_valet_object_ID address:self.orderObject.return_address orderStatus:_userOrderStatus];
                         
                         [self.mapSearchPlaceView hide];
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag hideInMapView:self.mapView];
                         [self.mapParkInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
                         
                         _isMyLocationBtnInOriginalPosition = YES;
                         [[self myLocationBtn] setFrame:_myLocationBtnFrame];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)setMapToUserOrderStatusPaymentPending {
    // 1. set status
    _userOrderStatus = kUserOrderStatusPaymentPending;
    
    // 2. set right navigation item to nil
    self.navigationItem.rightBarButtonItem = nil;
    
    // 3. update three maker - valet marker, flag marker and vehicle marker
    [self removeAllValetMarker];
    self.flagMarker.map = nil;
    self.vehicleMarker.map = nil;
    
    // 4. remove the route
    self.route.map = nil;
    
    // 5. update the view
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.mapPaymentView showInMapView:self.mapView];
                         [self.mapPaymentView setOrderObject:self.orderObject];
                         [self moveMyLocationBtn:-self.mapPaymentView.frame.size.height];
                         
                         [self.mapSearchPlaceView hide];
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag hideInMapView:self.mapView];
                         [self.mapValetInfoView hide];
                         [self.mapParkInfoView hide];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)setMapToUserOrderStatusFinished {
    [self setMapToUserOrderStatusNone:self.mapView.camera.target];
}

- (void)tryCancelOrder {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@""
                                        message:@"Are you sure you want to cancel this order?"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Yes, I am sure"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [self cancelOrder];
                                                         }];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"No"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                          }];
    [alert addAction:defaultAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)cancelOrder {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [[LibraryAPI sharedInstance] cancelAnOrderWithOrderObject:self.orderObject
                                                      success:^(OrderObject *orderObject) {
                                                          [hud hideAnimated:YES];
                                                          self.orderObject = nil;
                                                          [self setMapToUserOrderStatusNone:self.mapView.camera.target];
                                                      }
                                                         fail:^(NSError *error) {
                                                             [hud showMessage:@"cancel fail"];
                                                         }];
}

- (void)updateRequestServiceView:(CLLocationCoordinate2D)coordinate {
    if ([self checkIsPositionInPolygon:coordinate]) {
        _isInPolygon = YES;
        
        [self showRequestServiceView];
    } else {
        _isInPolygon = NO;
        
        [self hideRequestServiceView];
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
//    if ([[self.wilFlag text] isEqualToString:@"WIL"]) {
//        return;
//    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.requestValetButton showInMapView:self.mapView];
                         [self.requestValetButton setStatus:self.orderObject.order_status];
                         [self.wilFlag showWil];
                         [self.mapSearchPlaceView show];
                         [self moveMyLocationBtn:-self.requestValetButton.frame.size.height];
                         
                         if (_userOrderStatus == kUserOrderStatusParked) {
                             [self.mapParkInfoView show];
                         } else {
                             [self.mapParkInfoView hide];
                         }
                         
                         // hide other views
                         [self.mapValetInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)hideRequestServiceView {
//    if (![[self.wilFlag text] isEqualToString:@"WIL"]) {
//        return;
//    }
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         [self.mapSearchPlaceView show];
                         
                         // 0. hide the view at the bottom
                         [self.requestValetButton hideInMapView:self.mapView];
                         [self.wilFlag showGoToServiceArea];
                         _isMyLocationBtnInOriginalPosition = YES;
                         [[self myLocationBtn] setFrame:_myLocationBtnFrame];
                         
                         if (_userOrderStatus == kUserOrderStatusParked) {
                             [self.mapParkInfoView show];
                         } else {
                             [self.mapParkInfoView hide];
                         }
                         
                         // hide other views
                         [self.mapValetInfoView hide];
                         [self.mapPaymentView hideInMapView:self.mapView];
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

#pragma mark - Request Service

- (void)requestValetBtnClicked {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    // 1. check if there is any valet
    if (![[LibraryAPI sharedInstance] onlineValetLocations] || [[[LibraryAPI sharedInstance] onlineValetLocations] count] == 0) {
        [hud showMessage:@"try later, no valet online"];
        return;
    }
    
    // 2. find the nearest valet
    ValetLocation *nearestValetLocation = [[LibraryAPI sharedInstance] nearestValetLocation:self.mapView.camera.target];
    if (nearestValetLocation) {
        [nearestValetLocation fetchIfNeededInBackgroundWithBlock:^(AVObject * _Nullable object, NSError * _Nullable error) {
            if (!error) {
                // 3. create an order object
                if (_userOrderStatus == kUserOrderStatusNone) {
                    [[LibraryAPI sharedInstance] createAnOrderWithValetObjectID:nearestValetLocation.valet_object_ID
                                                          valetLocationObjectID:nearestValetLocation.objectId
                                                                    parkAddress:[self.mapSearchPlaceView meetAddress]
                                                                   parkLocation:[AVGeoPoint geoPointWithLatitude:self.mapView.camera.target.latitude
                                                                                                       longitude:self.mapView.camera.target.longitude]
                                                                        success:^(OrderObject *orderObject) {
                                                                            NSLog(@"successfully generate an order");
                                                                            [hud hideAnimated:YES];
                                                                            self.orderObject = orderObject;
                                                                            
                                                                            [self setMapToUserOrderStatusUserDroppingOff];
                                                                        }
                                                                           fail:^(NSError *error) {
                                                                               [hud showMessage:@"try create order later"];
                                                                           }];
                } else if (_userOrderStatus == kUserOrderStatusParked) {
                    // update the order to return the vehicle
                    [[LibraryAPI sharedInstance] requestingVehicleBackWithOrderObject:self.orderObject
                                                                        valetObjectID:nearestValetLocation.valet_object_ID
                                                                valetLocationObjectID:nearestValetLocation.objectId
                                                                        returnAddress:[self.mapSearchPlaceView meetAddress]
                                                                       returnLocation:[AVGeoPoint geoPointWithLatitude:self.mapView.camera.target.latitude
                                                                                                             longitude:self.mapView.camera.target.longitude]
                                                                           returnTime:[NSDate date]
                                                                              success:^(OrderObject *orderObject) {
                                                                                  NSLog(@"successfully update the order");
                                                                                  [hud hideAnimated:YES];
                                                                                  self.orderObject = orderObject;
                                                                                  
                                                                                  [self setMapToUserOrderStatusRequestingBack];
                                                                              }
                                                                                 fail:^(NSError *error) {
                                                                                     [hud showMessage:@"try request back later"];
                                                                                 }];
                }
            } else {
                [hud showMessage:@"try later, can not fetch valet's location"];
            }
        }];
    } else {
        [hud showMessage:@"try later, valets are busy"];
        return;
    }
    
    NSLog(@"asdf");
}

#pragma mark - Valet Marker

- (void)fetchValetsLocation {
    NSLog(@"try to get valets' locations");
    if (!_isGettingValetsLocations && _userOrderStatus != kUserOrderStatusPaymentPending) {
        _isGettingValetsLocations = YES;
        
        [[LibraryAPI sharedInstance] fetchValetsLocationsWithStatus:_userOrderStatus
                                                        orderObject:self.orderObject
                                                       valetMarkers:self.valetMarkers
                                                            success:^(NSArray *array) {
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
    
    // 4. check if need to change marker icon
    if (_userOrderStatus == kUserOrderStatusParking ||
        _userOrderStatus == kUserOrderStatusReturningBack) {
        for (ValetMarker *marker in self.valetMarkers) {
            marker.icon = [UIImage imageNamed:@"valet_in_vehicle_marker"];
        }
    } else {
        for (ValetMarker *marker in self.valetMarkers) {
            marker.icon = [UIImage imageNamed:@"valet_marker"];
        }
    }
    
    // 5. fit bounds with valet location
    [self fitBounds];
    
    // 6. finish
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
    [self requestLocationService];
}

#pragma mark - MapFlagDelegate

- (void)flagBtnClicked {
    [self moveToServiceArea];
}

#pragma mark - MapSearchViewDelegate

- (void)searchBtnClicked {
    [self launchSearch];
}

#pragma mark - User 

- (void)checkCurrentUser {
    // if there is no user now, show the Instruction page
    if (![AVUser currentUser]) {
        UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"InstructionNav"];
        InstructionViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        [self presentViewController:navVC animated:_isSignInAnimated completion:nil];
    } else {
        [self requestLocationService];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations.count) {
        CLLocation *location = locations.firstObject;
        NSLog(@"latitude:%f, longitude:%f", location.coordinate.latitude, location.coordinate.longitude);
        AVGeoPoint *geoPoint = [AVGeoPoint geoPointWithLocation:location];
        
        [[LibraryAPI sharedInstance] uploadClientLocation:geoPoint
                                               successful:^(ClientLocation *clientLocation) {
                                                   NSLog(@"upload location successfully");
                                               }
                                                     fail:^(NSError *error) {
                                                         NSLog(@"fail to upload client's location");
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

#pragma mark - MapValetInfoViewDelegate 

- (void)callValetWithNumber:(NSString *)mobilePhoneNumber {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSURL *phoneUrl = [NSURL URLWithString:[NSString  stringWithFormat:@"telprompt:%@", mobilePhoneNumber]];
    
    if ([[UIApplication sharedApplication] canOpenURL:phoneUrl]) {
        [[UIApplication sharedApplication] openURL:phoneUrl];
        [hud hideAnimated:YES];
    } else {
        [hud showMessage:@"Call facility is not available!"];
    }
}

#pragma mark - MapPaymentViewDelegate

- (void)applePayBtnClicked:(NSDecimalNumber *)amount {
    PKPaymentRequest *request = [[PKPaymentRequest alloc] init];
    NSArray *supportedPaymentNetworks = [NSArray arrayWithObjects:PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex, nil];
    NSString *applePayMerchantID = @"merchant.com.xianyang.wil-user";
    request.merchantIdentifier  = applePayMerchantID;
    request.supportedNetworks = supportedPaymentNetworks;
    request.merchantCapabilities = PKMerchantCapability3DS;
    request.countryCode = @"HK";
    request.currencyCode = @"HKD";
    request.paymentSummaryItems = [NSArray arrayWithObjects:
                                   [PKPaymentSummaryItem summaryItemWithLabel:@"item"
                                                                       amount:amount], nil];
    
    
    PKPaymentAuthorizationViewController *applePayController = [[PKPaymentAuthorizationViewController alloc] initWithPaymentRequest:request];
    applePayController.delegate = self;
    [self presentViewController:applePayController animated:YES completion:nil];

}

- (void)paymentAuthorizationViewController:(PKPaymentAuthorizationViewController *)controller
                       didAuthorizePayment:(PKPayment *)payment
                                completion:(void (^)(PKPaymentAuthorizationStatus status))completion {
    completion(PKPaymentAuthorizationStatusSuccess);
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[LibraryAPI sharedInstance] updateAnOrderWithOrderObject:self.orderObject
                                                     toStatus:kUserOrderStatusFinished
                                                      success:^(OrderObject *orderobject) {
                                                          [hud showMessage:@"Recieved your payment"];
                                                          self.orderObject = nil;
                                                          [self setMapToUserOrderStatusNone:self.mapView.camera.target];
                                                      }
                                                         fail:^(NSError *error) {
                                                             
                                                         }];
}

- (void)paymentAuthorizationViewControllerDidFinish:(PKPaymentAuthorizationViewController *)controller {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (MapSearchPlaceView *)mapSearchPlaceView {
    if (!_mapSearchPlaceView) {
        _mapSearchPlaceView = [[MapSearchPlaceView alloc] initWithFrame:CGRectMake(10, -MAP_SEARCH_PLACE_VIEW_HEIGHT, DEVICE_WIDTH - 20, MAP_SEARCH_PLACE_VIEW_HEIGHT)];
        _mapSearchPlaceView.delegate = self;
        _mapSearchPlaceView.backgroundColor = [UIColor whiteColor];
    }
    
    return _mapSearchPlaceView;
}

- (MapValetInfoView *)mapValetInfoView {
    if (!_mapValetInfoView) {
        _mapValetInfoView = [[MapValetInfoView alloc] initWithFrame:CGRectMake(10, - MAP_VALET_INFO_VIEW_HEIGHT, DEVICE_WIDTH - 20, MAP_VALET_INFO_VIEW_HEIGHT)];
        _mapValetInfoView.delegate = self;
        _mapValetInfoView.backgroundColor = [UIColor whiteColor];
    }
    
    return _mapValetInfoView;
}

- (MapParkInfoView *)mapParkInfoView {
    if (!_mapParkInfoView) {
        _mapParkInfoView = [[MapParkInfoView alloc] initWithFrame:CGRectMake(10, -MAP_PARK_INFO_VIEW_HEIGHT, DEVICE_WIDTH - 20, MAP_PARK_INFO_VIEW_HEIGHT)];
    }
    
    return _mapParkInfoView;
}

- (RequestValetButton *)requestValetButton {
    if (!_requestValetButton) {
        _requestValetButton = [[RequestValetButton alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, DEVICE_WIDTH, REQUEST_VALET_BTN_HEIGHT)];
        [_requestValetButton addTarget:self action:@selector(requestValetBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _requestValetButton;
}

- (MapPaymentView *)mapPaymentView {
    if (!_mapPaymentView) {
        _mapPaymentView = [[MapPaymentView alloc] initWithFrame:CGRectMake(0, self.mapView.frame.size.height, DEVICE_WIDTH, MAP_PAYMENT_INFO_VIEW_HEIGHT)];
        _mapPaymentView.delegate = self;
    }
    
    return _mapPaymentView;
}

- (MapFlag *)wilFlag {
    if (!_wilFlag) {
        _wilFlag = [[MapFlag alloc] init];
        _wilFlag.delegate = self;
    }
    
    return _wilFlag;
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

- (NSTimer *)orderStatusTimer {
    if (!_orderStatusTimer) {
        _orderStatusTimer = [NSTimer scheduledTimerWithTimeInterval:3
                                                             target:self
                                                           selector:@selector(fetchOrderStatus)
                                                           userInfo:nil
                                                            repeats:YES];
    }
    
    return _orderStatusTimer;
}

- (NSMutableArray *)valetMarkers {
    if (!_valetMarkers) {
        _valetMarkers = [[NSMutableArray alloc] init];
    }
    
    return _valetMarkers;
}

- (GMSMarker *)flagMarker {
    if (!_flagMarker) {
        _flagMarker = [[GMSMarker alloc] init];
        _flagMarker.icon = [UIImage imageNamed:@"flag_marker"];
        _flagMarker.appearAnimation = kGMSMarkerAnimationPop;
    }
    
    return _flagMarker;
}

- (GMSMarker *)vehicleMarker {
    if (!_vehicleMarker) {
        _vehicleMarker = [[GMSMarker alloc] init];
        _vehicleMarker.icon = [UIImage imageNamed:@"vehicle_marker"];
        _vehicleMarker.appearAnimation = kGMSMarkerAnimationPop;
    }
    
    return _vehicleMarker;
}

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    
    return _locationManager;
}

- (GMSPolyline *)route {
    if (!_route) {
        _route = [[GMSPolyline alloc] init];
    }
    
    return _route;
}

- (void)dealloc {
    [self.mapView removeObserver:self
                      forKeyPath:@"myLocation"
                         context:NULL];
}

# pragma mark - Search for a place

- (void)launchSearch {
    GMSAutocompleteViewController *acController = [[GMSAutocompleteViewController alloc] init];
    
    UIColor *backgroundColor = [UIColor colorWithWhite:0.25f alpha:1.0f];
    UIColor *selectedTableCellBackgroundColor = [UIColor colorWithWhite:0.35f alpha:1.0f];
    UIColor *darkBackgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
    UIColor *primaryTextColor = [UIColor whiteColor];
    UIColor *highlightColor = [UIColor colorWithRed:0.75f green:1.0f blue:0.75f alpha:1.0f];
    UIColor *secondaryColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    UIColor *tintColor = [UIColor whiteColor];
    UIColor *searchBarTintColor = tintColor;
    UIColor *separatorColor = [UIColor colorWithRed:0.5f green:0.75f blue:0.5f alpha:0.30f];
    
    
    // Use UIAppearance proxies to change the appearance of UI controls in
    // GMSAutocompleteViewController. Here we use appearanceWhenContainedIn to localise changes to
    // just this part of the Demo app. This will generally not be necessary in a real application as
    // you will probably want the same theme to apply to all elements in your app.
    UIActivityIndicatorView *appearence = [UIActivityIndicatorView
                                           appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil];
    [appearence setColor:primaryTextColor];
    
    [[UINavigationBar appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil]
     setBarTintColor:darkBackgroundColor];
    [[UINavigationBar appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil]
     setTintColor:searchBarTintColor];
    
    // Color of typed text in search bar.
    NSDictionary *searchBarTextAttributes = @{
                                              NSForegroundColorAttributeName : searchBarTintColor,
                                              NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                              };
    [[UITextField appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil]
     setDefaultTextAttributes:searchBarTextAttributes];
    
    // Color of the "Search" placeholder text in search bar. For this example, we'll make it the same
    // as the bar tint color but with added transparency.
    CGFloat increasedAlpha = CGColorGetAlpha(searchBarTintColor.CGColor) * 0.75f;
    UIColor *placeHolderColor = [searchBarTintColor colorWithAlphaComponent:increasedAlpha];
    
    NSDictionary *placeholderAttributes = @{
                                            NSForegroundColorAttributeName : placeHolderColor,
                                            NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]]
                                            };
    NSAttributedString *attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:@"Search" attributes:placeholderAttributes];
    
    [[UITextField appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil]
     setAttributedPlaceholder:attributedPlaceholder];
    
    // Change the background color of selected table cells.
    UIView *selectedBackgroundView = [[UIView alloc] init];
    selectedBackgroundView.backgroundColor = selectedTableCellBackgroundColor;
    id tableCellAppearance =
    [UITableViewCell appearanceWhenContainedIn:[GMSAutocompleteViewController class], nil];
    [tableCellAppearance setSelectedBackgroundView:selectedBackgroundView];
    
    // Depending on the navigation bar background color, it might also be necessary to customise the
    // icons displayed in the search bar to something other than the default. The
    // setupSearchBarCustomIcons method contains example code to do this.
    
    acController.delegate = self;
    acController.tableCellBackgroundColor = backgroundColor;
    acController.tableCellSeparatorColor = separatorColor;
    acController.primaryTextColor = primaryTextColor;
    acController.primaryTextHighlightColor = highlightColor;
    acController.secondaryTextColor = secondaryColor;
    acController.tintColor = tintColor;
    // set the search bounds to Hong Kong
    acController.autocompleteBounds = [[GMSCoordinateBounds alloc] initWithCoordinate:CLLocationCoordinate2DMake(LEFT_TOP_CORNER_LATITUDE_HONG_KONG, LEFT_TOP_CORNER_LONGITUDE_HONG_KONG)
                                                                           coordinate:CLLocationCoordinate2DMake(RIGHT_BOTTOM_CORNER_LATITUDE_HONG_KONG, RIGHT_BOTTOM_CORNER_LONGITUDE_HONG_KONG)];
    [self presentViewController:acController animated:YES completion:nil];
}

// handle the user's selection
- (void)viewController:(GMSAutocompleteViewController *)viewController didAutocompleteWithPlace:(GMSPlace *)place {
    //    [self.mapView animateToLocation:place.coordinate];
    //    [self.mapView animateToZoom:DEFAULT_ZOOM_LEVEL];
    [self.mapView animateToCameraPosition:[GMSCameraPosition cameraWithTarget:place.coordinate zoom:DEFAULT_ZOOM_LEVEL]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
