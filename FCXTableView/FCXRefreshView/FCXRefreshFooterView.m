//
//  FCXRefreshFooterView.m
//  RefreshPrj
//
//  Created by fcx on 15/8/21.
//  Copyright (c) 2015年 fcx. All rights reserved.
//

#import "FCXRefreshFooterView.h"

@implementation FCXRefreshFooterView

- (void)setupStateText {
    self.normalStateText = @"上拉加载更多";
    self.pullingStateText = @"松开可加载更多";
    self.loadingStateText = @"正在加载更多...";
    self.noMoreDataStateText = @"没有更多数据";
}

- (void)addRefreshContentView {
    [super addRefreshContentView];
    CGFloat width = self.frame.size.width;
    
    //刷新状态
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(0, 0, width, 60);
    _statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    _statusLabel.textColor = FCXREFRESHTEXTCOLOR;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_statusLabel];
    
    //箭头图片
    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow"]];
    arrowImageView.frame = CGRectMake(width/2.0 - 100, 11, 15, 40);
    [self addSubview:arrowImageView];
    
    //转圈动画
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = CGRectMake(width/2.0 - 100, 10, 15, 40);
    [self addSubview:_activityView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _statusLabel.frame = CGRectMake(0, 0, self.frame.size.width, 60);
    if (!_autoLoadMore) {
        arrowImageView.frame = CGRectMake(self.frame.size.width/2.0 - 100, 11, 15, 40);
        _activityView.frame = CGRectMake(self.frame.size.width/2.0 - 100, 10, 15, 40);
    }
}


- (void)setAutoLoadMore:(BOOL)autoLoadMore {
    _autoLoadMore = autoLoadMore;
    if (_autoLoadMore) {//自动加载更多不显示箭头
        [arrowImageView removeFromSuperview];
        arrowImageView = nil;
        self.normalStateText = @"正在加载更多...";
        self.pullingStateText = @"正在加载更多...";
        self.loadingStateText = @"正在加载更多...";
    }
}

- (void)scrollViewContentSizeDidChange {
    CGRect frame = self.frame;
    frame.origin.y =  MAX(_scrollView.frame.size.height, _scrollView.contentSize.height);
    self.frame = frame;
}

- (void)scrollViewContentOffsetDidChange {
    if (self.refreshState == FCXRefreshStateNoMoreData) {//没有更多数据
        return;
    }
    
    //scrollview实际显示内容高度
    CGFloat realHeight = _scrollView.frame.size.height - _scrollViewOriginalEdgeInsets.top - _scrollViewOriginalEdgeInsets.bottom;
    /// 计算超出scrollView的高度
    CGFloat beyondScrollViewHeight = _scrollView.contentSize.height - realHeight;
    if (beyondScrollViewHeight <= 0) {
        //scrollView的实际内容高度没有超出本身高度不处理
        return;
    }
    
    //刚刚出现底部控件时出现的offsetY
    CGFloat offSetY = beyondScrollViewHeight - _scrollViewOriginalEdgeInsets.top;
    // 当前scrollView的contentOffsetY超出offsetY的高度
    CGFloat beyondOffsetHeight = _scrollView.contentOffset.y - offSetY;
    if (beyondOffsetHeight <= 0) {
        return;
    }

    if (self.autoLoadMore) {//如果是自动加载更多
        //大于偏移量，转为加载更多loading
        self.refreshState = FCXRefreshStateLoading;
        return;
    }
    
    if (_scrollView.isDragging) {
        if (beyondOffsetHeight > FCXHandingOffsetHeight) {//大于偏移量，转为pulling
            self.refreshState = FCXRefreshStatePulling;
        }else {//小于偏移量，转为正常normal
            self.refreshState = FCXRefreshStateNormal;
        }
    } else {
        if (self.refreshState == FCXRefreshStatePulling) {//如果是pulling状态，改为加载更多loading
            self.refreshState = FCXRefreshStateLoading;
        }else {
            self.refreshState = FCXRefreshStateNormal;
        }
    }
    
    if (self.pullingPercentHandler) {
        if (beyondOffsetHeight <= FCXHandingOffsetHeight) {
            //有时进度可能会到0.991..对精度要求没那么高可以忽略
            self.pullingPercent = beyondOffsetHeight/FCXHandingOffsetHeight;
        }
    }
}

- (void)setRefreshState:(FCXRefreshState)refreshState {
    FCXRefreshState lastRefreshState = _refreshState;
    if (_refreshState != refreshState) {
        _refreshState = refreshState;
        switch (refreshState) {
            case FCXRefreshStateNormal:
            {                
                _statusLabel.text = self.normalStateText;
                if (lastRefreshState == FCXRefreshStateLoading) {//之前是刷新过
                    arrowImageView.hidden = YES;
                } else {
                    arrowImageView.hidden = NO;
                }
                arrowImageView.hidden = NO;
                [_activityView stopAnimating];
                
                [UIView animateWithDuration:0.2 animations:^{
                    arrowImageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                    _scrollView.contentInset = _scrollViewOriginalEdgeInsets;
                }];                
            }
                break;
            case FCXRefreshStatePulling:
            {
                _statusLabel.text = self.pullingStateText;
                [UIView animateWithDuration:0.2 animations:^{
                    arrowImageView.transform = CGAffineTransformIdentity;
                }];
            }
                break;
            case FCXRefreshStateLoading:
            {
                _statusLabel.text = self.loadingStateText;
                [_activityView startAnimating];
                arrowImageView.hidden = YES;
                arrowImageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                [UIView animateWithDuration:0.2 animations:^{
                    UIEdgeInsets inset = _scrollView.contentInset;
                    inset.bottom += FCXHandingOffsetHeight;
                    _scrollView.contentInset = inset;
                    inset.bottom = self.frame.origin.y - _scrollView.contentSize.height + FCXHandingOffsetHeight;
                    _scrollView.contentInset = inset;
                }];
                
                if (self.refreshHandler) {
                    self.refreshHandler(self);
                }
            }
                break;
            case FCXRefreshStateNoMoreData:
            {
                _statusLabel.text = self.noMoreDataStateText;
            }
                break;
        }
    }
}

- (void)showNoMoreData {
    [self endRefresh];
    self.refreshState = FCXRefreshStateNoMoreData;
    arrowImageView.hidden = YES;
}

- (void)resetNoMoreData {
    self.refreshState = FCXRefreshStateNormal;
}

@end
