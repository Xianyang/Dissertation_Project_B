//
//  PaymentViewController.m
//  Wil_User
//
//  Created by xianyang on 21/01/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import "PaymentViewController.h"

@interface PaymentViewController ()

@end

@implementation PaymentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setNavigationBar];
    
    AVQuery *query = [AVQuery queryWithClassName:@"test_object"];
//    [query whereKey:@"location" nearGeoPoint:];

    
//    AVObject *todoFolder = [[AVObject alloc] initWithClassName:@"TodoFolder"];// 构建对象
//    [todoFolder setObject:@"工作" forKey:@"name"];// 设置名称
//    [todoFolder setObject:@1 forKey:@"priority"];// 设置优先级
//    
//    AVObject *todo1 = [[AVObject alloc] initWithClassName:@"Todo"];
//    [todo1 setObject:@"工程师周会" forKey:@"title"];
//    [todo1 setObject:@"每周工程师会议，周一下午2点" forKey:@"content"];
//    [todo1 setObject:@"会议室" forKey:@"location"];
//    
//    AVObject *todo2 = [[AVObject alloc] initWithClassName:@"Todo"];
//    [todo2 setObject:@"维护文档" forKey:@"title"];
//    [todo2 setObject:@"每天 16：00 到 18：00 定期维护文档" forKey:@"content"];
//    [todo2 setObject:@"当前工位" forKey:@"location"];
//    
//    AVObject *todo3 = [[AVObject alloc] initWithClassName:@"Todo"];
//    [todo3 setObject:@"发布 SDK" forKey:@"title"];
//    [todo3 setObject:@"每周一下午 15：00" forKey:@"content"];
//    [todo3 setObject:@"SA 工位" forKey:@"location"];
//    
//    
//    
//    [AVObject saveAllInBackground:@[todo1,todo2,todo3] block:^(BOOL succeeded, NSError *error) {
//        if (error) {
//            // 出现错误
//        } else {
//            // 保存成功
//            AVRelation *relation = [todoFolder relationForKey:@"containedTodos"];// 新建一个 AVRelation
//            [relation addObject:todo1];
//            [relation addObject:todo2];
//            // 上述 2 行代码表示 relation 关联了 2 个 Todo 对象
//            
//            [todoFolder saveInBackground];// 保存到云端
//        }
//    }];
}

- (void)setNavigationBar {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"black"]
                                                  forBarMetrics:UIBarMetricsDefault];
    NSDictionary * dict=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
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
