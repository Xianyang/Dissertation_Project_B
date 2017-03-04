//
//  MainViewController.m
//  Wil_Valet
//
//  Created by xianyang on 02/03/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "MainViewController.h"
#import "SignInViewController.h"

@interface MainViewController () <SignInVCDelegate> {
    BOOL _isSignInAnimated;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    [self checkCurrentUser];
    [self requestLocationService];
}

- (void)requestLocationService {
    
}

- (void)getCurrentOrders {
    
}

#pragma mark - Sign in view controller delegate

- (void)doneProcessInSignInVC {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self getCurrentOrders];
}

#pragma mark - User

- (void)checkCurrentUser {
    // if there is no user now, show the Instruction page
    if (![AVUser currentUser]) {
        UINavigationController *navVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SignInVCNav"];
        SignInViewController *vc = [navVC.viewControllers objectAtIndex:0];
        vc.delegate = self;
        [self presentViewController:navVC animated:_isSignInAnimated completion:nil];
    } else {
        // current user is not nil
        [self getCurrentOrders];
    }
}

#pragma mark - Some Settings

- (void)setNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, [UIFont fontWithName:@"Gill Sans-UltraBold" size:18], NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self setNeedsStatusBarAppearanceUpdate];
    
    //    UIBarButtonItem *backButton =
    //    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", @"Back")
    //                                     style:UIBarButtonItemStylePlain
    //                                    target:nil
    //                                    action:nil];
    //    [self.navigationItem setBackBarButtonItem:backButton];
}

- (void)animateSignInView {
    _isSignInAnimated = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
