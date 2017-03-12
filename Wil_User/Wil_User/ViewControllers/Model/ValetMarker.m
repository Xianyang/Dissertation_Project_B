//
//  ValetMarker.m
//  Wil_User
//
//  Created by xianyang on 12/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "ValetMarker.h"

@implementation ValetMarker

- (id)initWithValetObjectID:(NSString *)valetObjectID AVGeoPoint:(AVGeoPoint *)geoPoint mapView:(GMSMapView *)mapView {
    self = [super init];
    
    if (self) {
        self.valetObjectID = valetObjectID;
        self.position = CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
        self.icon = [UIImage imageNamed:@"valet_marker"];
        self.isUpdate = YES;
        self.map = mapView;
    }
    
    return self;
}

@end
