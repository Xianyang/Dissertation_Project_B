//
//  VehicleInfoViewController.h
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderObject.h"

@interface VehicleInfoViewController : UIViewController

- (void)setOrder:(OrderObject *)order currentLocation:(CLLocation *)currentLocation Plate:(NSString *)plate model:(NSString *)model color:(NSString *)color image:(UIImage *)image imageURL:(NSString *)imageURL editable:(BOOL)editable;

@end
