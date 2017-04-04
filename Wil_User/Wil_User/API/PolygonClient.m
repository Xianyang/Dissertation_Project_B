//
//  PolygonClient.m
//  Wil_User
//
//  Created by xianyang on 20/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "PolygonClient.h"

@interface PolygonClient ()

@property (strong, nonatomic) GMSGeocoder *geoCoder;

@end

@implementation PolygonClient

- (GMSGeocoder *)geoCoder {
    if (!_geoCoder) {
        _geoCoder = [[GMSGeocoder alloc] init];
    }
    
    return _geoCoder;
}

- (void)reverseGeocodeCoordinate:(CLLocationCoordinate2D)coordinate success:(void(^)(GMSReverseGeocodeResponse *response))successBlock fail:(void (^)(NSError *error))failBlock {
    [self.geoCoder reverseGeocodeCoordinate:coordinate
                          completionHandler:^(GMSReverseGeocodeResponse * response, NSError * error) {
                              if (!error) {
                                  successBlock(response);
                              } else {
                                  failBlock(error);
                              }
                          }];
}

- (CLLocationCoordinate2D)serviceLocation {
    return CLLocationCoordinate2DMake(22.284689, 114.158152);
}

- (NSArray *)polygons {
    return @[[self polygonForHKIsland], [self polygonForKowloon]];
//    return @[[self polygonForHKIsland], [self polygonForKowloon], [self polygonForHome]];
}

- (GMSPolygon *)basicPolygon {
    GMSPolygon *polygon = [[GMSPolygon alloc] init];
    polygon.fillColor = [[LibraryAPI sharedInstance] themeLightBlueColor];
    polygon.strokeColor = [[LibraryAPI sharedInstance] themeBlueColor];
    polygon.strokeWidth = 1;
    polygon.tappable = YES;
    
    return polygon;
}

- (GMSPolygon *)polygonForHKIsland {
    GMSPolygon *polygon = [self basicPolygon];
    polygon.path = [self pathOfHKIsland];
    polygon.title = @"Hong Kong";
    
    return polygon;
}

- (GMSPolygon *)polygonForKowloon {
    GMSPolygon *polygon = [self basicPolygon];
    polygon.path = [self pathForKoowlon];
    polygon.title = @"Kowloon";
    
    return polygon;
}

- (GMSPolygon *)polygonForHome {
    GMSPolygon *polygon = [self basicPolygon];
    polygon.path = [self pathOfHome];
    polygon.title = @"Home";
    
    return polygon;
}

- (GMSPath *)pathOfHome {
    GMSMutablePath *path = [GMSMutablePath path];
    [path addLatitude:22.286838 longitude:114.135466];
    [path addLatitude:22.285458 longitude:114.135391];
    [path addLatitude:22.285359 longitude:114.137156];
    [path addLatitude:22.286803 longitude:114.136952];
    [path addLatitude:22.286838 longitude:114.135466];
    
    return path;
}

- (GMSPath *)pathOfHKIsland {
    GMSMutablePath *path = [GMSMutablePath path];
    [path addLatitude:22.287925 longitude:114.143765];
    [path addLatitude:22.284252 longitude:114.143593];
    [path addLatitude:22.284113 longitude:114.144301];
    [path addLatitude:22.284768 longitude:114.144967];
    [path addLatitude:22.284748 longitude:114.145567];
    [path addLatitude:22.284014 longitude:114.145975];
    [path addLatitude:22.283557 longitude:114.146426];
    [path addLatitude:22.283418 longitude:114.146962];
    [path addLatitude:22.283299 longitude:114.147649];
    [path addLatitude:22.282902 longitude:114.148486];
    [path addLatitude:22.282961 longitude:114.148979];
    [path addLatitude:22.282783 longitude:114.149537];
    [path addLatitude:22.282703 longitude:114.150352];
    [path addLatitude:22.280936 longitude:114.152219];
    [path addLatitude:22.279884 longitude:114.154000];
    [path addLatitude:22.279030 longitude:114.154236];
    [path addLatitude:22.279209 longitude:114.155138];
    [path addLatitude:22.280043 longitude:114.155588];
    [path addLatitude:22.280301 longitude:114.156125];
    [path addLatitude:22.279447 longitude:114.156404];
    [path addLatitude:22.279248 longitude:114.157069];
    [path addLatitude:22.279387 longitude:114.157948];
    [path addLatitude:22.278692 longitude:114.158227];
    [path addLatitude:22.277878 longitude:114.158034];
    [path addLatitude:22.277759 longitude:114.157605];
    [path addLatitude:22.277382 longitude:114.157755];
    [path addLatitude:22.277382 longitude:114.158936];
    [path addLatitude:22.277819 longitude:114.160888];
    [path addLatitude:22.278692 longitude:114.161811];
    [path addLatitude:22.278950 longitude:114.162991];
    [path addLatitude:22.278375 longitude:114.163935];
    [path addLatitude:22.277620 longitude:114.163399];
    [path addLatitude:22.276687 longitude:114.164064];
    [path addLatitude:22.276349 longitude:114.165244];
    [path addLatitude:22.277739 longitude:114.167304];
    [path addLatitude:22.277501 longitude:114.167733];
    [path addLatitude:22.276290 longitude:114.167025];
    [path addLatitude:22.275595 longitude:114.168420];
    [path addLatitude:22.275476 longitude:114.169514];
    [path addLatitude:22.274979 longitude:114.170287];
    [path addLatitude:22.275515 longitude:114.170759];
    [path addLatitude:22.274681 longitude:114.172153];
    [path addLatitude:22.273967 longitude:114.172132];
    [path addLatitude:22.273907 longitude:114.173291];
    [path addLatitude:22.274344 longitude:114.173334];
    [path addLatitude:22.274324 longitude:114.173934];
    [path addLatitude:22.272855 longitude:114.173570];
    [path addLatitude:22.272874 longitude:114.174256];
    [path addLatitude:22.273569 longitude:114.175200];
    [path addLatitude:22.274384 longitude:114.175286];
    [path addLatitude:22.274622 longitude:114.175887];
    [path addLatitude:22.274820 longitude:114.177668];
    [path addLatitude:22.274542 longitude:114.179063];
    [path addLatitude:22.273867 longitude:114.179277];
    [path addLatitude:22.270432 longitude:114.180329];
    [path addLatitude:22.270472 longitude:114.180672];
    [path addLatitude:22.273629 longitude:114.180007];
    [path addLatitude:22.274483 longitude:114.180157];
    [path addLatitude:22.276051 longitude:114.181058];
    [path addLatitude:22.276647 longitude:114.181294];
    [path addLatitude:22.277640 longitude:114.183547];
    [path addLatitude:22.277024 longitude:114.185307];
    [path addLatitude:22.279149 longitude:114.187646];
    [path addLatitude:22.280102 longitude:114.188955];
    [path addLatitude:22.284311 longitude:114.186273];
    [path addLatitude:22.282306 longitude:114.182990];
    [path addLatitude:22.284848 longitude:114.183419];
    [path addLatitude:22.284728 longitude:114.181895];
    [path addLatitude:22.283200 longitude:114.181745];
    [path addLatitude:22.282604 longitude:114.180222];
    [path addLatitude:22.283239 longitude:114.179964];
    [path addLatitude:22.284133 longitude:114.180994];
    [path addLatitude:22.284371 longitude:114.180844];
    [path addLatitude:22.283517 longitude:114.179621];
    [path addLatitude:22.283100 longitude:114.176424];
    [path addLatitude:22.283736 longitude:114.176338];
    [path addLatitude:22.283775 longitude:114.176016];
    [path addLatitude:22.282068 longitude:114.176123];
    [path addLatitude:22.282028 longitude:114.175844];
    [path addLatitude:22.282147 longitude:114.175758];
    [path addLatitude:22.282703 longitude:114.175715];
    [path addLatitude:22.282703 longitude:114.175415];
    [path addLatitude:22.282068 longitude:114.175372];
    [path addLatitude:22.282028 longitude:114.174986];
    [path addLatitude:22.282941 longitude:114.174964];
    [path addLatitude:22.283120 longitude:114.174385];
    [path addLatitude:22.284391 longitude:114.174600];
    [path addLatitude:22.285125 longitude:114.174364];
    [path addLatitude:22.285106 longitude:114.174128];
    [path addLatitude:22.284728 longitude:114.174149];
    [path addLatitude:22.284867 longitude:114.172969];
    [path addLatitude:22.284709 longitude:114.172239];
    [path addLatitude:22.284431 longitude:114.171939];
    [path addLatitude:22.282624 longitude:114.171402];
    [path addLatitude:22.282524 longitude:114.170866];
    [path addLatitude:22.282644 longitude:114.169858];
    [path addLatitude:22.281552 longitude:114.169171];
    [path addLatitude:22.281472 longitude:114.168613];
    [path addLatitude:22.282862 longitude:114.168828];
    [path addLatitude:22.282902 longitude:114.167969];
    [path addLatitude:22.283358 longitude:114.165823];
    [path addLatitude:22.284351 longitude:114.163141];
    [path addLatitude:22.284689 longitude:114.162712];
    [path addLatitude:22.286277 longitude:114.162047];
    [path addLatitude:22.286773 longitude:114.160995];
    [path addLatitude:22.288183 longitude:114.156017];
    [path addLatitude:22.288382 longitude:114.155223];
    [path addLatitude:22.287468 longitude:114.154150];
    [path addLatitude:22.287687 longitude:114.153743];
    [path addLatitude:22.286714 longitude:114.153421];
    [path addLatitude:22.288163 longitude:114.148228];
    [path addLatitude:22.288640 longitude:114.143786];
    
    return path;
}

- (GMSPath *)pathForKoowlon {
    GMSMutablePath *path = [GMSMutablePath path];
    [path addLatitude:22.292928 longitude:114.169493];
    [path addLatitude:22.293008 longitude:114.170909];
    [path addLatitude:22.293147 longitude:114.171016];
    [path addLatitude:22.293246 longitude:114.172690];
    [path addLatitude:22.292849 longitude:114.173226];
    [path addLatitude:22.292809 longitude:114.173934];
    [path addLatitude:22.292908 longitude:114.174836];
    [path addLatitude:22.294517 longitude:114.176225];
    [path addLatitude:22.295559 longitude:114.176617];
    [path addLatitude:22.296080 longitude:114.177083];
    [path addLatitude:22.297961 longitude:114.179342];
    [path addLatitude:22.298026 longitude:114.179299];
    [path addLatitude:22.299033 longitude:114.180517];
    [path addLatitude:22.299361 longitude:114.182475];
    [path addLatitude:22.298011 longitude:114.182518];
    [path addLatitude:22.297653 longitude:114.181981];
    [path addLatitude:22.297236 longitude:114.182110];
    [path addLatitude:22.297693 longitude:114.183054];
    [path addLatitude:22.299520 longitude:114.183011];
    [path addLatitude:22.299520 longitude:114.183741];
    [path addLatitude:22.298725 longitude:114.184191];
    [path addLatitude:22.300691 longitude:114.188912];
    [path addLatitude:22.301088 longitude:114.189878];
    [path addLatitude:22.300929 longitude:114.190028];
    [path addLatitude:22.301108 longitude:114.190543];
    [path addLatitude:22.301346 longitude:114.190500];
    [path addLatitude:22.301545 longitude:114.190843];
    [path addLatitude:22.301961 longitude:114.191015];
    [path addLatitude:22.301842 longitude:114.191401];
    [path addLatitude:22.301842 longitude:114.191594];
    [path addLatitude:22.301803 longitude:114.191766];
    [path addLatitude:22.302041 longitude:114.191916];
    [path addLatitude:22.302140 longitude:114.192109];
    [path addLatitude:22.302140 longitude:114.192195];
    [path addLatitude:22.302438 longitude:114.192495];
    [path addLatitude:22.302458 longitude:114.192688];
    [path addLatitude:22.302617 longitude:114.192731];
    [path addLatitude:22.302716 longitude:114.192946];
    [path addLatitude:22.302617 longitude:114.193289];
    [path addLatitude:22.302815 longitude:114.193268];
    [path addLatitude:22.302835 longitude:114.193075];
    [path addLatitude:22.303768 longitude:114.192817];
    [path addLatitude:22.308354 longitude:114.193804];
    [path addLatitude:22.309902 longitude:114.191787];
    [path addLatitude:22.310160 longitude:114.191852];
    [path addLatitude:22.310180 longitude:114.192259];
    [path addLatitude:22.310498 longitude:114.192259];
    [path addLatitude:22.310577 longitude:114.191830];
    [path addLatitude:22.314488 longitude:114.192002];
    [path addLatitude:22.314647 longitude:114.192581];
    [path addLatitude:22.314865 longitude:114.192495];
    [path addLatitude:22.317862 longitude:114.194019];
    [path addLatitude:22.319431 longitude:114.194899];
    [path addLatitude:22.320225 longitude:114.195414];
    [path addLatitude:22.320860 longitude:114.196186];
    [path addLatitude:22.322210 longitude:114.194384];
    [path addLatitude:22.324592 longitude:114.189920];
    [path addLatitude:22.327450 longitude:114.191551];
    [path addLatitude:22.328403 longitude:114.191551];
    [path addLatitude:22.327847 longitude:114.187260];
    [path addLatitude:22.332214 longitude:114.187517];
    [path addLatitude:22.335786 longitude:114.187860];
    [path addLatitude:22.338485 longitude:114.188204];
    [path addLatitude:22.340708 longitude:114.188290];
    [path addLatitude:22.342534 longitude:114.188290];
    [path addLatitude:22.343249 longitude:114.184170];
    [path addLatitude:22.344360 longitude:114.181852];
    [path addLatitude:22.344440 longitude:114.178162];
    [path addLatitude:22.344122 longitude:114.175501];
    [path addLatitude:22.342534 longitude:114.174471];
    [path addLatitude:22.342455 longitude:114.173183];
    [path addLatitude:22.343169 longitude:114.171724];
    [path addLatitude:22.342772 longitude:114.170952];
    [path addLatitude:22.342058 longitude:114.170179];
    [path addLatitude:22.341264 longitude:114.169064];
    [path addLatitude:22.340946 longitude:114.167948];
    [path addLatitude:22.341661 longitude:114.166317];
    [path addLatitude:22.341661 longitude:114.164858];
    [path addLatitude:22.341423 longitude:114.163313];
    [path addLatitude:22.340867 longitude:114.161339];
    [path addLatitude:22.341740 longitude:114.159536];
    [path addLatitude:22.342534 longitude:114.158506];
    [path addLatitude:22.342614 longitude:114.154987];
    [path addLatitude:22.340232 longitude:114.155760];
    [path addLatitude:22.331975 longitude:114.148378];
    [path addLatitude:22.330149 longitude:114.147778];
    [path addLatitude:22.327767 longitude:114.146404];
    [path addLatitude:22.325862 longitude:114.149151];
    [path addLatitude:22.325386 longitude:114.150267];
    [path addLatitude:22.324115 longitude:114.151726];
    [path addLatitude:22.323004 longitude:114.152842];
    [path addLatitude:22.322130 longitude:114.151983];
    [path addLatitude:22.321416 longitude:114.152412];
    [path addLatitude:22.322448 longitude:114.153700];
    [path addLatitude:22.321177 longitude:114.154902];
    [path addLatitude:22.316810 longitude:114.154987];
    [path addLatitude:22.316810 longitude:114.159193];
    [path addLatitude:22.315540 longitude:114.159880];
    [path addLatitude:22.306964 longitude:114.159880];
    [path addLatitude:22.303470 longitude:114.157305];
    [path addLatitude:22.303470 longitude:114.154987];
    [path addLatitude:22.302279 longitude:114.154301];
    [path addLatitude:22.299420 longitude:114.154387];
    [path addLatitude:22.298626 longitude:114.154987];
    [path addLatitude:22.298646 longitude:114.158034];
    [path addLatitude:22.299162 longitude:114.158270];
    [path addLatitude:22.299698 longitude:114.158936];
    [path addLatitude:22.300234 longitude:114.160180];
    [path addLatitude:22.300909 longitude:114.166059];
    [path addLatitude:22.300889 longitude:114.166961];
    [path addLatitude:22.294298 longitude:114.168441];
    [path addLatitude:22.293444 longitude:114.168935];
    
    return path;
}

@end
