//
//  InstructionViewController.m
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define PAGE_CONTROL_WIDTH 26.0f
#define PAGE_CONTROL_HEIGHT 37.0f

#import "InstructionViewController.h"
#import "InstructionPage.h"
#import "SetPhoneViewController.h"

@interface InstructionViewController () <UIScrollViewDelegate>
{
    NSInteger _pageCount;
}

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSMutableArray *imageViews;
@property (strong, nonatomic) NSMutableArray *pages;

@end

@implementation InstructionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _pageCount = 3;
    [self setBasicView];
    [self buildScrollViewWithFrame];
    [self buildPageArray];
    [self buildPageControl];
    
}

- (void)setBasicView {
    // 1. add background image
//    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.view.frame];
//    bgImageView.image = [UIImage imageNamed:@"Instruction_Bg"];
//    [self.view addSubview:bgImageView];
    
    // 2. add title
//    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 26.0f)];
//    title.text = @"WIL";
//    title.textColor = [UIColor whiteColor];
//    title.textAlignment = NSTextAlignmentCenter;
//    title.font = [UIFont systemFontOfSize:20.0f];
//    [self.view addSubview:title];
    
    // 3. add sign in button
//    UIButton *signInBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - 71.0f, 33, 50, 16)];
//    [signInBtn setTitle:@"Sign In" forState:UIControlStateNormal];
//    [signInBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
//    [signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [signInBtn addTarget:self action:@selector(signInBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:signInBtn];
    
    // 4. add sign up button
//    UIButton *signUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 60.0f, self.view.frame.size.width, 17.0f)];
//    [signUpBtn setTitle:@"Continue with Phone" forState:UIControlStateNormal];
//    [signUpBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
//    [signUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [signUpBtn addTarget:self action:@selector(signUpBtnClicked) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:signUpBtn];
}

- (IBAction)signInBtnClicked:(id)sender {
    NSLog(@"user signs in");
}

- (IBAction)signUpBtnClicked:(id)sender {
    NSLog(@"user wants to sign up");
    
    SetPhoneViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SetPhoneViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)buildScrollViewWithFrame
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - 100 - 100)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(DEVICE_WIDTH * _pageCount, self.scrollView.frame.size.height);
    
    [self.view addSubview:self.scrollView];
    
    for (NSInteger i = 0; i <= _pageCount; i++) {
        [self loadScrollViewWithPageIndex:i];
    }
}

- (void)buildPageArray {
    self.pages = [[NSMutableArray alloc] initWithObjects:[NSNull null], [NSNull null], [NSNull null], nil];
}

- (void)buildPageControl
{
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake((DEVICE_WIDTH - PAGE_CONTROL_WIDTH) / 2, DEVICE_HEIGHT - 110.0f, PAGE_CONTROL_WIDTH, PAGE_CONTROL_HEIGHT)];
    self.pageControl.numberOfPages = _pageCount;
    self.pageControl.currentPage = 0;
    
    [self.view addSubview:self.pageControl];
}

- (void)loadScrollViewWithPageIndex:(NSInteger)pageIndex
{
    if (pageIndex < 0) {
        return;
    }
    if (pageIndex >= _pageCount) {
        return;
    }
    
    InstructionPage *page = self.pages[pageIndex];
    if (!page) {
        page = [[InstructionPage alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height) pageIndex:pageIndex];
        [self.pages replaceObjectAtIndex:pageIndex withObject:page];
    }
    
    if (self.scrollView) {
        CGRect frame = self.scrollView.frame;
        frame.size.width = DEVICE_WIDTH;
        frame.origin.x = frame.size.width * pageIndex;
        frame.origin.y = 0.0f;
        [page setFrame:frame];
        [self.scrollView addSubview:page];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
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
