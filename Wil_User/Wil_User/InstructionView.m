//
//  InstructionView.m
//  Designer
//
//  Created by 罗 显扬 on 15/2/14.
//  Copyright (c) 2015年 罗 显扬. All rights reserved.
//

#import "InstructionView.h"
#import "InstructionPage.h"

#define PAGE_CONTROL_WIDTH 26.0f
#define PAGE_CONTROL_HEIGHT 37.0f

@interface InstructionView() {
    NSInteger _pageCount;
}

@end

@implementation InstructionView

- (id)initWithFrame:(CGRect)frame withPanelCount:(NSInteger)count
{
    self = [super initWithFrame:frame];
    if (self) {
        _pageCount = count;
        [self setBasicView];
        [self buildScrollViewWithFrame];
        [self buildPageArray];
        [self buildPageControl];
    }
    
    return self;
}

- (void)setBasicView {
    // 1. add background image
    UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:self.frame];
    bgImageView.image = [UIImage imageNamed:@"Instruction_Bg"];
    [self addSubview:bgImageView];
    
    // 2. add title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 26.0f)];
    title.text = @"WIL";
    title.textColor = [UIColor whiteColor];
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:20.0f];
    [self addSubview:title];
    
    // 3. add sign in button
    UIButton *signInBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 71.0f, 33, 50, 16)];
    [signInBtn setTitle:@"Sign In" forState:UIControlStateNormal];
    [signInBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [signInBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signInBtn addTarget:self action:@selector(signInBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:signInBtn];
    
    // 4. add sign up button
    UIButton *signUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 60.0f, self.frame.size.width, 17.0f)];
    [signUpBtn setTitle:@"Continue with Phone" forState:UIControlStateNormal];
    [signUpBtn.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    [signUpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpBtn addTarget:self action:@selector(signUpBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:signUpBtn];
}

- (void)signInBtnClicked {
    NSLog(@"user signs in");
}

- (void)signUpBtnClicked {
    NSLog(@"user wants to sign up");
}

- (void)buildScrollViewWithFrame
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 100, self.frame.size.width, self.frame.size.height - 100 - 100)];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(DEVICE_WIDTH * _pageCount, self.scrollView.frame.size.height);
    
    [self addSubview:self.scrollView];
    
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
    
    [self addSubview:self.pageControl];
}

- (void)showInView:(UIView *)view
{
    //Add introduction view
    self.alpha = 1;
    [view addSubview:self];
    
    //Fade in
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    }];
}

-(void)hideWithFadeOutDuration
{
    //Fade out
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"pushtoCaipinList"];
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
    
//    UIImageView *imageView = self.imageViews[pageIndex];
//    if (!imageView) {
//        imageView = [[UIImageView alloc] init];
//        if (pageIndex) {
//            if (DEVICE_WIDTH == 414.0f) {
//                imageView.image = [UIImage imageNamed:@"引导2-1242_2208"];
//            } else if (DEVICE_WIDTH == 375.0f) {
//                imageView.image = [UIImage imageNamed:@"引导2-750_1334"];
//            } else {
//                if (DEVICE_HEIGHT == 480.0f) {
//                    imageView.image = [UIImage imageNamed:@"引导2-640_960"];
//                } else {
//                    imageView.image = [UIImage imageNamed:@"引导2-640_1136"];
//                }
//            }
//            
//            imageView.userInteractionEnabled = YES;
//            
//            UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(50.0f, DEVICE_HEIGHT - 110.0f, 210.0f, 70.0f)];
//            button.backgroundColor = [UIColor clearColor];
//            [button addTarget:self action:@selector(hideWithFadeOutDuration) forControlEvents:UIControlEventTouchUpInside];
//            [imageView addSubview:button];
//            
//        } else {
//            if (DEVICE_WIDTH == 414.0f) {
//                imageView.image = [UIImage imageNamed:@"引导1-1242_2208"];
//            } else if (DEVICE_WIDTH == 375.0f) {
//                imageView.image = [UIImage imageNamed:@"引导1-750_1334"];
//            } else {
//                if (DEVICE_HEIGHT == 480.0f) {
//                    imageView.image = [UIImage imageNamed:@"引导1-640_960"];
//                } else {
//                    imageView.image = [UIImage imageNamed:@"引导1-640_1136"];
//                }
//            }
//        }
//        
//        [self.imageViews replaceObjectAtIndex:pageIndex withObject:imageView];
//    }
    
//    if (self.scrollView) {
//        CGRect frame = self.scrollView.frame;
//        frame.size.width = [UIScreen mainScreen].bounds.size.width;
//        frame.origin.x = frame.size.width * pageIndex;
//        frame.origin.y = 0.0f;
//        [imageView setFrame:frame];
//        [self.scrollView addSubview:imageView];
//    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
    // which a scroll event generated from the user hitting the page control triggers updates from
    // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
    if (_pageControlUsed)
    {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Switch the indicator when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    
    // load the visible page and the page on either side of it (to avoid flashes when the user starts scrolling)
    //    [self loadScrollViewWithPageIndex:page - 1];
    //    [self loadScrollViewWithPageIndex:page];
    //    [self loadScrollViewWithPageIndex:page + 1];
    
    // A possible optimization would be to unload the views+controllers which are no longer visible
}


@end
