//
//  PolygonClient.h
//  Wil_User
//
//  Created by xianyang on 20/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface PolygonClient : NSObject

- (NSArray *)polygons;
- (GMSPolygon *)polygonForHKIsland;
- (GMSPolygon *)polygonForKowloon;

- (CLLocationCoordinate2D)serviceLocation;

@end
