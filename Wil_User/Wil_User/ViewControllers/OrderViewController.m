//
//  OrderViewController.m
//  Wil_User
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderCell.h"
#import "OrderObject.h"

static NSString * const OrderCellIdentifier = @"OrderCell";

@interface OrderViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *orders;
@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self getOrderForCustomer];
}

- (void)getOrderForCustomer {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    AVQuery *finishOrderQuery = [AVQuery queryWithClassName:@"Order"];
    [finishOrderQuery whereKey:@"order_status" equalTo:@(kUserOrderStatusFinished)];
    
    AVQuery *cancelOrderQuery = [AVQuery queryWithClassName:@"Order"];
    [cancelOrderQuery whereKey:@"order_status" equalTo:@(kUserOrderStatusCancel)];
    
    AVQuery *orderStatusQuery = [AVQuery orQueryWithSubqueries:@[finishOrderQuery, cancelOrderQuery]];
    
    AVQuery *userQuery = [AVQuery queryWithClassName:@"Order"];
    [userQuery whereKey:@"user_object_ID" equalTo:[[AVUser currentUser] objectId]];
    
    AVQuery *query = [AVQuery andQueryWithSubqueries:@[orderStatusQuery, userQuery]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (!error) {
            if (objects.count) {
                [hud hideAnimated:YES];
                self.orders = [[objects reverseObjectEnumerator] allObjects];
                [self.tableView reloadData];
            } else {
                [hud showMessage:@"No Orders"];
            }
            
        } else {
            [hud showMessage:@"Fetch orders failed, try again"];
        }
    }];
}

#pragma mark - UITableView

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.orders.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    OrderCell *cell = [tableView dequeueReusableCellWithIdentifier:OrderCellIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(OrderCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    OrderObject *order = self.orders[indexPath.row];
    
    cell.dropOffAddress.text = order.drop_off_address;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.serivceTime.text = [NSString stringWithFormat:@"%@ - %@", [self stringFromDate:order.request_park_at], [self stringFromDate:order.updatedAt]];
    
    if (order.order_status == kUserOrderStatusFinished) {
        cell.serviceFee.text = [NSString stringWithFormat:@"$%.1f", [order.payment_amount floatValue]];
    } else {
        cell.serviceFee.text = @"$0";
        cell.serviceStatus.text = @"canceled";
        cell.serviceStatus.textColor = [UIColor orangeColor];
    }
}

- (NSString *)stringFromDate:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM HH:mm"];
    
    //Optionally for time zone conversions
//    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"..."]];
    
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}

- (NSArray *)orders {
    if (!_orders) {
        _orders = [[NSArray alloc] init];
    }
    
    return _orders;
}

- (void)setNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
