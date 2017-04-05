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

- (void)setOrder:(OrderObject *)order Plate:(NSString *)plate model:(NSString *)model color:(NSString *)color imageURL:(NSString *)imageURL;

@end
