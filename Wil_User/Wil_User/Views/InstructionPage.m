//
//  InstructionPage.m
//  Wil_User
//
//  Created by xianyang on 23/02/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#define VIEW_PIC_SPACE 62.0f
#define PIC_TITLE_SPACE 44.0f
#define TITLE_CONTENT_SPACE 19.0f

#import "InstructionPage.h"

@interface InstructionPage()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *title;
@property (strong, nonatomic) UILabel *content1;
@property (strong, nonatomic) UILabel *content2;

@end

@implementation InstructionPage

- (id)initWithFrame:(CGRect)frame pageIndex:(NSInteger)pageIndex {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self addPic:pageIndex];
        [self addText:pageIndex];
    }
    
    return self;
}

- (void)addPic:(NSInteger)pageIndex {
    CGFloat imageWidth = [[InstructionPage imageSizes][pageIndex][0] floatValue];
    CGFloat imageHeight = [[InstructionPage imageSizes][pageIndex][1] floatValue];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.frame.size.width - imageWidth) / 2, VIEW_PIC_SPACE, imageWidth, imageHeight)];
    self.imageView.image = [UIImage imageNamed:[InstructionPage imageNames][pageIndex]];
    [self addSubview:self.imageView];
}

- (void)addText:(NSInteger)pageIndex {
    // 1. add title
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.imageView.frame.origin.y + self.imageView.frame.size.height + PIC_TITLE_SPACE, self.frame.size.width, 26.0f)];
    self.title.text = [InstructionPage titles][pageIndex];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.textColor = [UIColor whiteColor];
    self.title.font = [UIFont systemFontOfSize:20.0f];
    [self addSubview:self.title];
    
    // 2. add content
    self.content1 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.title.frame.origin.y + self.title.frame.size.height + TITLE_CONTENT_SPACE, self.frame.size.width, 20.0f)];
    self.content1.text = [InstructionPage contents][pageIndex * 2];
    self.content1.textAlignment = NSTextAlignmentCenter;
    self.content1.textColor = [UIColor whiteColor];
    self.content1.font = [UIFont systemFontOfSize:18.0f];
    [self addSubview:self.content1];
    
    self.content2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, self.content1.frame.origin.y + self.content1.frame.size.height + 10, self.frame.size.width, 20.0f)];
    self.content2.text = [InstructionPage contents][pageIndex * 2 + 1];
    self.content2.textAlignment = NSTextAlignmentCenter;
    self.content2.textColor = [UIColor whiteColor];
    self.content2.font = [UIFont systemFontOfSize:18.0f];
    [self addSubview:self.content2];
}

+ (NSArray *)imageNames {
    return @[@"instruction_pic1", @"instruction_pic2", @"instruction_pic3"];
}

+ (NSArray *)imageSizes {
    return @[@[@180, @141], @[@157, @157], @[@208, @146]];
}

+ (NSArray *)titles {
    return @[@"VALET PARKING", @"POINT TO POINT", @"CASHLESS"];
}

+ (NSArray *)contents {
    return @[@"Never worry about parking again.",
             @"Request a valet with a tap of button.",
             @"Have your car picked up and returned",
             @"where you want, when you want.",
             @"Keep your wallet in your pocket, all",
             @"payment is handled within the app."];
}

@end
