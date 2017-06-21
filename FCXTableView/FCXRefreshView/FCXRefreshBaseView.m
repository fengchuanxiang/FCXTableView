//
//  FCXRefreshBaseView.m
//  RefreshPrj
//
//  Created by fcx on 15/8/21.
//  Copyright (c) 2015年 fcx. All rights reserved.
//

#import "FCXRefreshBaseView.h"


@implementation FCXRefreshBaseView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addRefreshContentView];
        [self setupStateText];
        self.refreshState = FCXRefreshStateNormal;
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    [self removeScrollViewObservers];
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (UIScrollView *)newSuperview;
        _scrollViewOriginalEdgeInsets = _scrollView.contentInset;
        [self addScrollViewObservers];
    }
}

- (void)addRefreshContentView {}
- (void)setupStateText {}
- (void)autoRefresh {}
- (void)endRefresh {
    self.refreshState = FCXRefreshStateNormal;
}
- (void)showNoMoreData {}
- (void)resetNoMoreData {}
- (void)setPullingPercent:(CGFloat)pullingPercent {
    if (_pullingPercent != pullingPercent) {
        _pullingPercent = pullingPercent;
        if (_pullingPercentHandler) {
            _pullingPercentHandler(_pullingPercent);
        }
    }
}

#pragma mark - KVO
- (void)addScrollViewObservers {
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
    [_scrollView addObserver:self forKeyPath:@"contentInset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeScrollViewObservers {
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        [self.superview removeObserver:self forKeyPath:@"contentOffset" context:nil];
        [self.superview removeObserver:self forKeyPath:@"contentSize" context:nil];
        [self.superview removeObserver:self forKeyPath:@"contentInset" context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        //正在刷新
        if (_refreshState == FCXRefreshStateLoading) {
            return;
        }
        [self scrollViewContentOffsetDidChange];
    } else if ([keyPath isEqualToString:@"contentSize"]) {
        [self scrollViewContentSizeDidChange];
    } else if ([keyPath isEqualToString:@"contentInset"]) {
        if (_refreshState == FCXRefreshStateLoading) {
            return;
        }
        _scrollViewOriginalEdgeInsets = _scrollView.contentInset;
    }
}

- (void)scrollViewContentOffsetDidChange {}
- (void)scrollViewContentSizeDidChange {}

@end
