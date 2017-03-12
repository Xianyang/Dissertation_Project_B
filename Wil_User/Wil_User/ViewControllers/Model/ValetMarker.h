//
//  ValetMarker.h
//  Wil_User
//
//  Created by xianyang on 12/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <GoogleMaps/GoogleMaps.h>

@interface ValetMarker : GMSMarker

- (id)initWithValetObjectID:(NSString *)valetObjectID AVGeoPoint:(AVGeoPoint *)geoPoint mapView:(GMSMapView *)mapView;

@property (strong, nonatomic) NSString *valetObjectID;
@property (assign ,nonatomic) BOOL isUpdate;

@end
