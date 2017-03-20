//
//  AVGeoPoint+CoordinateWithGeoPoint.h
//  Wil_User
//
//  Created by xianyang on 17/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "ValetLocation.h"
#import "ClientLocation.h"

@interface AVGeoPoint (CoordinateWithGeoPoint)

- (CLLocationCoordinate2D)coordinateWithGeoPoint:(AVGeoPoint *)geoPoint;
- (CLLocationCoordinate2D)coordinateWithValetLocationObject:(ValetLocation *)valetLocation;
- (CLLocationCoordinate2D)coordinateWithClientLocationObject:(ClientLocation *)clientLocation;

- (CLLocation *)locationWithGeoPoint:(AVGeoPoint *)geoPoint;

@end
