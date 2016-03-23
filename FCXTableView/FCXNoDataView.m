//
//  FCXNoDataView.m
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXNoDataView.h"

@implementation FCXNoDataView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor redColor];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(buttonAction) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitle:@"没有数据点击看看\n下拉刷新、上拉加载跟多" forState:UIControlStateNormal];
        btn.frame = CGRectMake((frame.size.width - 230)/2.0, (frame.size.height - 100)/2.0, 230, 100);
        [self addSubview:btn];
    }
    return self;
}

- (void)buttonAction {
    if (self.noDataActionBlock) {
        self.noDataActionBlock();
    }
}

@end
