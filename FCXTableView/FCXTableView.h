//
//  FCXTableView.h
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FCXNoDataView.h"

/**
 *  选中某行
 *
 *  @param indexPath 位置
 *  @param data      数据
 */
typedef void(^FCXDidSelectRowBlock)(NSIndexPath *indexPath, id data);


/**
 *  note:这里父类实现的UITableViewDataSource的代理方法仅供参考，
 *  调用时注意要写registerClass:forCellReuseIdentifier:，
 *  如有特殊功能样式可自行实现.
 */
@interface FCXTableView : UITableView


@property (nonatomic, strong) NSMutableArray *groupArray;//!<数据源（需要分组，有多组的，里面的数据一定要是数组）
@property (nonatomic, strong) NSMutableArray *dataArray;//!<数据源(不需要分组或只有一组的)
@property (nonatomic, copy) FCXDidSelectRowBlock didSelectRowBlock;//!<选中某行的操作
@property (nonatomic, copy) FCXNoDataActionBlock noDataActionBlock;//!<无数据点击的操作
@property (nonatomic, strong) Class noDataViewClass;//!<无数据时显示的类，默认是FCXNoDataView



@end
