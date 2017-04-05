//
//  TakeVehicleImageViewController.h
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderObject.h"

@interface TakeVehicleImageViewController : UIViewController

- (void)setOrderObject:(OrderObject *)order currentLocation:(CLLocation *)currentLocation;

@end
