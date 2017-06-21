//
//  UIScrollView+FCXRefresh.m
//  RefreshDemo
//
//  Created by fcx on 15/8/25.
//  Copyright (c) 2015年 fcx. All rights reserved.
//

#import "UIScrollView+FCXRefresh.h"
#import "FCXRefreshHeaderView.h"
#import "FCXRefreshFooterView.h"

@implementation UIScrollView (FCXRefresh)

- (FCXRefreshHeaderView *)addHeaderWithRefreshHandler:(FCXRefreshedHandler)refreshHandler {
    FCXRefreshHeaderView *header = [[FCXRefreshHeaderView alloc] initWithFrame:CGRectMake(0, -60, [UIScreen mainScreen].bounds.size.width, 60)];
    header.refreshHandler = refreshHandler;
    [self addSubview:header];
    return header;
}

- (FCXRefreshFooterView *)addFooterWithRefreshHandler:(FCXRefreshedHandler)refreshHandler {
    FCXRefreshFooterView *footer = [[FCXRefreshFooterView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 60)];
    footer.refreshHandler = refreshHandler;
    [self addSubview:footer];
    return footer;
}

@end
