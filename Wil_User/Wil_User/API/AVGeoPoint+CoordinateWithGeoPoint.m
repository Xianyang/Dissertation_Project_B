//
//  AVGeoPoint+CoordinateWithGeoPoint.m
//  Wil_User
//
//  Created by xianyang on 17/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "AVGeoPoint+CoordinateWithGeoPoint.h"

@implementation AVGeoPoint (CoordinateWithGeoPoint)

- (CLLocationCoordinate2D)coordinateWithGeoPoint:(AVGeoPoint *)geoPoint {
    return CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude);
}

- (CLLocationCoordinate2D)coordinateWithValetLocationObject:(ValetLocation *)valetLocation {
    return CLLocationCoordinate2DMake(valetLocation.valet_location.latitude, valetLocation.valet_location.longitude);
}

- (CLLocationCoordinate2D)coordinateWithClientLocationObject:(ClientLocation *)clientLocation {
    return CLLocationCoordinate2DMake(clientLocation.client_location.latitude, clientLocation.client_location.longitude);
}

@end
