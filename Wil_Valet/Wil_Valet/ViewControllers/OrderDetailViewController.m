//
//  OrderDetailViewController.m
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define DEFAULT_ZOOM_LEVEL                          15.5

#import "OrderDetailViewController.h"

@interface OrderDetailViewController () <GMSMapViewDelegate> {
    BOOL _isMapSetted;
    BOOL _firstLocationUpdate;
    BOOL _isMyLocationBtnInOriginalPosition;
    BOOL _isGettingClientLocation;
    
    CGRect _myLocationBtnFrame;
}

// the timer for update client's location
@property (strong, nonatomic) NSTimer *clientLocationTimer;

@property (strong, nonatomic) OrderObject *orderObject;
@property (strong, nonatomic) ClientObject *clientObject;
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (strong, nonatomic) GMSMarker *clientMarker;
@property (strong, nonatomic) GMSMarker *flagMarker;

@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isMapSetted = NO;
    _firstLocationUpdate = NO;
    _isMyLocationBtnInOriginalPosition = YES;
    _isGettingClientLocation = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // fetch client's location
    [self.clientLocationTimer setFireDate:[NSDate date]];
    [self fetchClientLocation];
    
    if (!_isMapSetted) {
        self.mapView.hidden = YES;
        [self setMap];
        _isMapSetted = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.clientLocationTimer setFireDate:[NSDate distantFuture]];
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
    
    // Draw the polygon
    for (GMSPolygon *polygon in [[LibraryAPI sharedInstance] polygons]) {
        polygon.map = self.mapView;
    }
    
    // add flag marker
    self.flagMarker.position = CLLocationCoordinate2DMake(self.orderObject.park_location.latitude, self.orderObject.park_location.longitude);
    
    // TODO add client marker
    
    
    // ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        self.mapView.myLocationEnabled = YES;
    });
    
    // set view according to order status
    [self checkOrderStatus];
}

// get the valet's location for the first time
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
        self.mapView.hidden = NO;
    }
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position {

}

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {

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

#pragma mark - Order 

- (void)checkOrderStatus {
    if (self.orderObject.order_status == kUserOrderStatusUserDroppingOff) {
        [self setMapToUserOrderStatusUserDroppingOff];
    } else if (self.orderObject.order_status == kUserOrderStatusParking) {
        [self setMapToUserOrderStatusParking];
    } else if (self.orderObject.order_status == kUserOrderStatusRequestingBack) {
        [self setMapToUserOrderStatusRequestingBack];
    } else {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud showMessage:@"error with order status"];
    }
}

- (void)setMapToUserOrderStatusUserDroppingOff {
    
}

- (void)setMapToUserOrderStatusParking {
    
}

- (void)setMapToUserOrderStatusRequestingBack {
    
}


#pragma mark - Client location

- (void)fetchClientLocation {
    if (!_isGettingClientLocation) {
        _isGettingClientLocation = YES;
        [[LibraryAPI sharedInstance] fetchClientLocationWithClientObjectID:self.clientObject.objectId
                                                                   success:^(ClientLocation *clientLocation) {
                                                                       _isGettingClientLocation = NO;
                                                                       self.clientMarker.position = CLLocationCoordinate2DMake(clientLocation.client_location.latitude,
                                                                                                                               clientLocation.client_location.longitude);
                                                                   }
                                                                      fail:^(NSError *error) {
                                                                          _isGettingClientLocation = NO;
                                                                      }];
    }
}


- (void)setOrder:(OrderObject *)orderObject client:(ClientObject *)clientObject {
    self.orderObject = orderObject;
    self.clientObject = clientObject;
}

- (void)dealloc {
    [self.mapView removeObserver:self
                      forKeyPath:@"myLocation"
                         context:NULL];
}

- (GMSMarker *)clientMarker {
    if (!_clientMarker) {
        _clientMarker = [[GMSMarker alloc] init];
        _clientMarker.icon = [UIImage imageNamed:@"client_marker"];
        _clientMarker.map = self.mapView;
    }
    
    return _clientMarker;
}

- (GMSMarker *)flagMarker {
    if (!_flagMarker) {
        _flagMarker = [[GMSMarker alloc] init];
        _flagMarker.icon = [UIImage imageNamed:@"flag_marker"];
        _flagMarker.map = self.mapView;
    }
    
    return _flagMarker;
}

- (NSTimer *)clientLocationTimer {
    if (!_clientLocationTimer) {
        _clientLocationTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                                target:self
                                                              selector:@selector(fetchClientLocation)
                                                              userInfo:nil
                                                               repeats:YES];
    }
    
    return _clientLocationTimer;
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
