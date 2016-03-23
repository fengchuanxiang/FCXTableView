//
//  ViewController.m
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "ViewController.h"
#import "FCXTableView.h"
#import "FCXTableViewCell.h"
#import "UIScrollView+FCXRefresh.h"

@interface ViewController ()
{
    FCXTableView *_tableView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView = [[FCXTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [_tableView registerClass:[FCXTableViewCell class] forCellReuseIdentifier:@"FCXCellIdentifier"];
    [self.view addSubview:_tableView];
    
    [self addRefreshHeaderAndFooter];
    [self setupTableViewAction];
}


- (void)addRefreshHeaderAndFooter {
    __block int t = 1;
    __weak FCXTableView *weakTableView = _tableView;
    
    //添加下拉刷新
    [_tableView addHeaderWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakTableView.groupArray = @[@[@"1-1", @"1-2", @"1-3"], @[@"2-1", @"2-2", @"2-3"], @[@"3-1", @"3-2", @"3-3"], @[@"4-1", @"4-2", @"4-3"], @[@"5-1", @"5-2", @"5-3"], @[@"6-1", @"6-2", @"6-3"]];
            t = 1;
            [refreshView endRefresh];
        });
    }];
    
    //添加上拉加载更多
    [_tableView addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {
        NSMutableArray *groupArray = [[NSMutableArray alloc] initWithArray:weakTableView.groupArray];
        NSMutableArray *moreArray = [NSMutableArray array];
        for (int i = 0; i < 6; i++) {
            [moreArray addObject:[NSString stringWithFormat:@"增加组%d - %d", t, i + 1]];
        }
        t++;
        [groupArray addObject:moreArray];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakTableView.groupArray = groupArray;
            [refreshView endRefresh];
        });
    }];
}

- (void)setupTableViewAction {
    //点击某行
    _tableView.didSelectRowBlock = ^(NSIndexPath *indexPath, id data) {
        NSLog(@"点击了 第%ld组 第%ld行 数据内容是：%@", indexPath.section, indexPath.row, data);
    };
    
    //无数据时点击
    _tableView.noDataActionBlock = ^(){
        NSLog(@"无数据点击了");
    };
}

@end
