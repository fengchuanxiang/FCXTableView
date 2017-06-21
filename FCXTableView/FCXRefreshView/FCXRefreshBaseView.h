//
//  FCXRefreshBaseView.h
//  RefreshPrj
//
//  Created by fcx on 15/8/21.
//  Copyright (c) 2015年 fcx. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, FCXRefreshState) {
    FCXRefreshStateNormal = 1,
    FCXRefreshStatePulling = 2,
    FCXRefreshStateLoading = 3,
    FCXRefreshStateNoMoreData = 4 //上拉加载显示没有更多数据
};

typedef NS_ENUM(NSInteger, FCXRefreshViewType) {
    FCXRefreshViewTypeHeader = -1,
    FCXRefreshViewTypeFooter = 1
};

//刷新偏移量的高度
static const CGFloat FCXHandingOffsetHeight = 60;
//文本颜色
#define FCXREFRESHTEXTCOLOR [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0]

@class FCXRefreshBaseView;
typedef void(^FCXRefreshedHandler)(FCXRefreshBaseView *refreshView);
typedef void(^FCXPullingPercentHandler)(CGFloat pullingPercent);


@interface FCXRefreshBaseView : UIView
{
    UILabel *_timeLabel;
    UILabel *_statusLabel;
    UIImageView *arrowImageView;
    UIActivityIndicatorView *_activityView;
    __weak UIScrollView *_scrollView;//!<添加刷新的scrollView
    UIEdgeInsets _scrollViewOriginalEdgeInsets;
    FCXRefreshState _refreshState;//!<当前刷新状态
}

@property (nonatomic, copy) FCXRefreshedHandler refreshHandler;//!<刷新的相应事件
@property (nonatomic, unsafe_unretained) FCXRefreshState refreshState;//!<当前刷新状态
@property (nonatomic, unsafe_unretained) CGFloat pullingPercent;
@property (nonatomic, copy) FCXPullingPercentHandler pullingPercentHandler;//!<刷新的相应事件

@property (nonatomic, copy) NSString *normalStateText;//!<正常状态文本
@property (nonatomic, copy) NSString *pullingStateText;//!<下拉状态提示文本
@property (nonatomic, copy) NSString *loadingStateText;//!<加载中的提示文本
@property (nonatomic, copy) NSString *noMoreDataStateText;//!<没有更多数据提示文本


//设置各种状态的文本
- (void)setupStateText;

/**
 *  添加刷新的界面
 *
 *  注：如果想自定义刷新加载界面，可在子类中重写该方法进行布局子界面
 */
- (void)addRefreshContentView;
//自动刷新
- (void)autoRefresh;
//结束刷新
- (void)endRefresh;
// 当scrollView的contentOffset发生改变的时候调用
- (void)scrollViewContentOffsetDidChange;
// 当scrollView的contentSize发生改变的时候调用
- (void)scrollViewContentSizeDidChange;
//显示没有更多数据
- (void)showNoMoreData;
//重置没有更多的数据（消除没有更多数据的状态）
- (void)resetNoMoreData;

@end
