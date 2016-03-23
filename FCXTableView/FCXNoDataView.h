//
//  FCXNoDataView.h
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  没有数据点击时的操作
 */
typedef void (^FCXNoDataActionBlock)(void);

@interface FCXNoDataView : UIView


@property (nonatomic, copy) FCXNoDataActionBlock noDataActionBlock;

@end
