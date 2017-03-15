//
//  OrderDetailViewController.h
//  Wil_Valet
//
//  Created by xianyang on 15/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderObject.h"
#import "ClientObject.h"

@interface OrderDetailViewController : UIViewController

- (void)setOrder:(OrderObject *)orderObject client:(ClientObject *)clientObject;

@end
