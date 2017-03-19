//
//  ProfileViewController.m
//  Wil_User
//
//  Created by xianyang on 20/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define PROFILE_IMAGE_WIDTH 100
#define EDIT_IMAGE_WIDTH    31


#import "ProfileViewController.h"
#import "ProfileCell.h"
#import "ChangeInfoViewContoller.h"

static NSString * const ProfileCellIdentifier = @"ProfileCell";

@interface ProfileViewController () <UITableViewDataSource, UITableViewDelegate, ChangeInfoViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
}

#pragma mark - ChangeInfoViewControllerDelegate

- (void)cancelBtnClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveSuccessfully {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.tableView reloadData];
}

#pragma mark - UITableView

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (!section) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 150)];
        view.backgroundColor = [UIColor whiteColor];
        
        
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - PROFILE_IMAGE_WIDTH) / 2, (view.frame.size.height - PROFILE_IMAGE_WIDTH) / 2,
                                                                                      PROFILE_IMAGE_WIDTH, PROFILE_IMAGE_WIDTH)];
        profileImageView.image = [UIImage imageNamed:@"default_profile_image"];
        profileImageView.layer.masksToBounds = YES;
        profileImageView.layer.cornerRadius = PROFILE_IMAGE_WIDTH / 2;
        [view addSubview:profileImageView];
        
        UIImageView *editImageView = [[UIImageView alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x, profileImageView.frame.origin.y + profileImageView.frame.size.height - EDIT_IMAGE_WIDTH, EDIT_IMAGE_WIDTH, EDIT_IMAGE_WIDTH)];
        editImageView.image = [UIImage imageNamed:@"edit"];
        editImageView.layer.masksToBounds = YES;
        editImageView.layer.cornerRadius = EDIT_IMAGE_WIDTH / 2;
        [view addSubview:editImageView];
        
        return view;
    } else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (!section) {
        return 150;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section) {
        [self logOutBtnClicked];
    } else {
        AVUser *user = [AVUser currentUser];
        UINavigationController *navC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChangeInfoNavC"];
        ChangeInfoViewContoller *vc = (ChangeInfoViewContoller *)[navC topViewController];
        vc.delegate = self;
        if (indexPath.row == 1) {
            [vc setkey:@"first_name" object:user];
            [self presentViewController:navC animated:YES completion:nil];
        } else if (indexPath.row == 2) {
            [vc setkey:@"last_name" object:user];
            [self presentViewController:navC animated:YES completion:nil];
        } else if (indexPath.row == 3) {
            // TODO change password
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section?40:60;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section?1:4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        UITableViewCell *logoutCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                             reuseIdentifier:@"LogOutCell"];
        logoutCell.textLabel.text = @"Log Out";
        logoutCell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return logoutCell;
    } else {
        ProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:ProfileCellIdentifier
                                                            forIndexPath:indexPath];
        
        [self configureCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

- (void)configureCell:(ProfileCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section) {
        
    } else {
        AVUser *user = [AVUser currentUser];
        
        cell.firstLabel.text = [ProfileViewController titleLabelForCell][indexPath.row];
        if (indexPath.row == 0) {
            cell.secondLabel.text = user.mobilePhoneNumber;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else if (indexPath.row == 1) {
            cell.secondLabel.text = [user objectForKey:@"first_name"];
        } else if (indexPath.row == 2) {
            cell.secondLabel.text = [user objectForKey:@"last_name"];
        } else if (indexPath.row == 3) {
            cell.secondLabel.text = @"******";
        }
    }
}

+ (NSArray *)titleLabelForCell {
    return @[@"Phone Number", @"First Name", @"Last Name", @"Password"];
}

#pragma mark - Log out

- (void)logOutBtnClicked {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:@""
                                        message:@"Logout wil delete data. You can log in to use our service"
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *logoutAction = [UIAlertAction actionWithTitle:@"Log Out"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [AVUser logOut];
                                                             [self.delegate userLogout];
                                                         }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             
                                                         }];
    [alert addAction:logoutAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
    
    
}

#pragma mark - Some Settings

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
