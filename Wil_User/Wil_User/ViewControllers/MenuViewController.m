//
//  MenuViewController.m
//  Wil_User
//
//  Created by xianyang on 20/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MenuViewController.h"
#import "RESideMenu.h"
#import "SideMenuCell.h"
#import "MainViewController.h"
#import "ProfileViewController.h"

static NSString * const SideMenuCellIdentifier = @"SideMenuCell";

@interface MenuViewController () <UITableViewDataSource, UITableViewDelegate, RESideMenuDelegate, ProfileVCDelegate>

@property (strong, readwrite, nonatomic) UITableView *tableaView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.opaque = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.bounces = NO;
    self.tableView.scrollsToTop = NO;
}

#pragma mark - Profile View Controller Delegate

- (void)userLogout {
    MainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
    [vc animateSignInView];
    [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:vc]];
}

#pragma mark -
#pragma mark UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 1) {
        ProfileViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        vc.delegate = self;
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:vc]];
    } else {
        [self.sideMenuViewController setContentViewController:[[UINavigationController alloc] initWithRootViewController:[self.storyboard instantiateViewControllerWithIdentifier:[MenuViewController nameOfContentVC][indexPath.row]]]
                                                     animated:YES];
    }
    
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SideMenuCell *cell = [self.tableView dequeueReusableCellWithIdentifier:SideMenuCellIdentifier
                                                         forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(SideMenuCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    cell.backgroundColor = [UIColor clearColor];
    cell.sideCellLabel.font = [UIFont fontWithName:@"Lucida Grande" size:18];
    cell.sideCellLabel.textColor = [UIColor whiteColor];
    cell.sideCellLabel.highlightedTextColor = [UIColor lightGrayColor];
//    cell.selectedBackgroundView = [[UIView alloc] init];

    cell.sideCellLabel.text = [MenuViewController cellTitles][indexPath.row];
    cell.sideCellImageView.image = [UIImage imageNamed:[MenuViewController cellImageNames][indexPath.row]];
}

+ (NSArray *)cellTitles {
    return @[@"HOME", @"PROFILE", @"ORDERS", @"SUBSCRIPTIONS", @"ABOUT", @"CONTACT"];
}

+ (NSArray *)cellImageNames {
    return @[@"menu_home", @"menu_profile", @"menu_payment", @"menu_subscriptions", @"menu_about", @"menu_contact"];
}

+ (NSArray *)nameOfContentVC {
    return @[@"MainViewController", @"ProfileViewController", @"OrderViewController", @"SubscriptionsViewController", @"AboutViewController", @"ContactViewController"];
}

@end
