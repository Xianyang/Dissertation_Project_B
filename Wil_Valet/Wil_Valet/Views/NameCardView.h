//
//  NameCardView.h
//  Wil_Valet
//
//  Created by xianyang on 05/04/2017.
//  Copyright © 2017 xianyang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NameCardViewDelegate

- (void)closeBtnClicked;

@end

@interface NameCardView : UIView

- (id)initWithFrame:(CGRect)frame;
- (void)show;

@property (assign, nonatomic) id <NameCardViewDelegate> delegate;

@end
