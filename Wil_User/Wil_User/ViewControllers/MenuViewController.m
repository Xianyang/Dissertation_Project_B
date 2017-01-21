//
//  MenuViewController.m
//  Wil_User
//
//  Created by xianyang on 20/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MenuViewController.h"
#import "RESideMenu.h"

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate>

@property (strong, readwrite, nonatomic) UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height - 54 * 5) / 2.0f, self.view.frame.size.width, 54 * 6) style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.opaque = NO;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.backgroundView = nil;
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tableView.bounces = NO;
        tableView.scrollsToTop = NO;
        tableView;
    });
    [self.view addSubview:self.tableView];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:[MenuViewController nameOfContentVC][indexPath.row]]]
                                                 animated:YES];
    [self.sideMenuViewController hideMenuViewController];
}

#pragma mark -
#pragma mark UITableView Datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:21];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.highlightedTextColor = [UIColor lightGrayColor];
        cell.selectedBackgroundView = [[UIView alloc] init];
    }
    
    cell.textLabel.text = [MenuViewController cellTitles][indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[MenuViewController cellImageNames][indexPath.row]];
    
    return cell;
}

+ (NSArray *)cellTitles {
    return @[@"HOME", @"PROFILE", @"PAYMENT", @"SUBSCRIPTIONS", @"ABOUT", @"CONTACT"];
}

+ (NSArray *)cellImageNames {
    return @[@"menu_home", @"menu_profile", @"menu_payment", @"menu_subscriptions", @"menu_about", @"menu_contact"];
}

+ (NSArray *)nameOfContentVC {
    return @[@"MainViewController", @"ProfileViewController", @"PaymentViewController", @"SubscriptionsViewController", @"AboutViewController", @"ContactViewController"];
}

@end
