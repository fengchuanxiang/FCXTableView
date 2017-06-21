//
//  FCXRefreshHeaderView.m
//  RefreshPrj
//
//  Created by fcx on 15/8/21.
//  Copyright (c) 2015年 fcx. All rights reserved.
//

#import "FCXRefreshHeaderView.h"

@implementation FCXRefreshHeaderView

- (void)setupStateText {
    self.normalStateText = @"下拉刷新";
    self.pullingStateText = @"松开可刷新";
    self.loadingStateText = @"正在刷新...";
}

- (void)addRefreshContentView {
    [super addRefreshContentView];
    CGFloat width = self.frame.size.width;

    //刷新状态
    _statusLabel = [[UILabel alloc] init];
    _statusLabel.frame = CGRectMake(0, 15, width, 20);
    _statusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    _statusLabel.textColor = FCXREFRESHTEXTCOLOR;
    _statusLabel.backgroundColor = [UIColor clearColor];
    _statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_statusLabel];

    //更新时间
    _timeLabel = [[UILabel alloc] init];
    _timeLabel.frame = CGRectMake(0, 35, width, 20);
    _timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    _timeLabel.textColor = [UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1.0];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_timeLabel];
    
    //箭头图片
    arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blueArrow"]];
    arrowImageView.frame = CGRectMake(width/2.0 - 100, (FCXHandingOffsetHeight - 40)/2.0 + 5, 15, 40);
    [self addSubview:arrowImageView];
    
    //转圈动画
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.frame = arrowImageView.frame;
    [self addSubview:_activityView];
    [self updateTimeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _statusLabel.frame = CGRectMake(0, self.frame.size.height - 45, self.frame.size.width, 20);
    _timeLabel.frame = CGRectMake(0, 35, self.frame.size.width, 20);
    arrowImageView.frame = CGRectMake(self.frame.size.width/2.0 - 100, (FCXHandingOffsetHeight - 40)/2.0 + 5, 15, 40);
    _activityView.frame = arrowImageView.frame;
}

- (void)scrollViewContentOffsetDidChange {
    if (_scrollView.contentOffset.y > -_scrollViewOriginalEdgeInsets.top) {
        //向上滚动到看不见头部控件，直接返回
        return;
    }

    if (_scrollView.isDragging) {//正在拖拽
        if (_scrollView.contentOffset.y + _scrollViewOriginalEdgeInsets.top < -FCXHandingOffsetHeight) {//大于偏移量，转为pulling
            self.refreshState = FCXRefreshStatePulling;
        }else {//小于偏移量，转为正常normal
            self.refreshState = FCXRefreshStateNormal;
        }
    } else {
        if (self.refreshState == FCXRefreshStatePulling) {//如果是pulling状态，改为刷新加载loading
            self.refreshState = FCXRefreshStateLoading;
        }else  {
            self.refreshState = FCXRefreshStateNormal;
        }
    }
    
    if (self.pullingPercentHandler) {
        CGFloat offsetHeight = -_scrollView.contentOffset.y - _scrollViewOriginalEdgeInsets.top;
        if (offsetHeight >= 0 && offsetHeight <= FCXHandingOffsetHeight) {
            //有时进度可能会到0.991..对精度要求没那么高可以忽略
            self.pullingPercent = offsetHeight/FCXHandingOffsetHeight;
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
                if (lastRefreshState == FCXRefreshStateLoading) {//之前是在刷新
                    [self updateTimeLabel];
                }
                arrowImageView.hidden = NO;
                [_activityView stopAnimating];
                
                [UIView animateWithDuration:0.2 animations:^{
                    arrowImageView.transform = CGAffineTransformIdentity;
                    _scrollView.contentInset = _scrollViewOriginalEdgeInsets;
                }];
            }
                break;
            case FCXRefreshStatePulling:
            {
                _statusLabel.text = self.pullingStateText;
                [UIView animateWithDuration:0.2 animations:^{
                    arrowImageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                }];
            }
                break;
            case FCXRefreshStateLoading:
            {
                _statusLabel.text = self.loadingStateText;
                [_activityView startAnimating];
                arrowImageView.hidden = YES;
                arrowImageView.transform = CGAffineTransformIdentity;

                [UIView animateWithDuration:0.2 animations:^{
                    UIEdgeInsets edgeInset = _scrollViewOriginalEdgeInsets;
                    edgeInset.top += FCXHandingOffsetHeight;
                    _scrollView.contentInset = edgeInset;
                }];

                if (self.refreshHandler) {
                    self.refreshHandler(self);
                }
            }
                break;
            case FCXRefreshStateNoMoreData:
            {
            }
                break;
        }
    }
}

- (void)autoRefresh {
    self.refreshState = FCXRefreshStateLoading;
    [UIView animateWithDuration:.2 animations:^{
       _scrollView.contentOffset = CGPointMake(0, -FCXHandingOffsetHeight);
    } completion:^(BOOL finished) {
        self.refreshState = FCXRefreshStateLoading;
    }];
}

- (void)updateTimeLabel {
    NSMutableDictionary *threadDictionary = [[NSThread currentThread] threadDictionary] ;
    NSDateFormatter *dateFormatter = [threadDictionary objectForKey: @"FCXRefeshDateFormatterKey"] ;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init] ;
        [dateFormatter setDateFormat: @"最后更新：今天 HH:mm"] ;
        [threadDictionary setObject: dateFormatter forKey: @"FCXRefeshDateFormatterKey"] ;
    }
    _timeLabel.text = [dateFormatter stringFromDate:[NSDate date]];
}

@end
