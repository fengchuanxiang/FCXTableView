//
//  FCXTableView.m
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXTableView.h"


@interface FCXTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSString *cellIdentifier;
@property (nonatomic, strong) UITableViewCell *noDataCell;

@end

@implementation FCXTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        [self fcx_setUp];
    }
    return self;
}

- (void)fcx_setUp {
    self.delegate = self;
    self.dataSource = self;
    //清除没有数据cell的横线
    self.tableFooterView = [[UIView alloc] init];
}

- (void)setGroupArray:(NSMutableArray *)groupArray {
    NSAssert(groupArray, @"groupArray必须是数组类型");

    if (![groupArray isKindOfClass:[NSArray class]]) {
        return;
    }
    
    if (_groupArray != groupArray) {
        _groupArray = groupArray;
        [self reloadData];
    }
}

- (void)setDataArray:(NSMutableArray *)dataArray {
    NSAssert(dataArray, @"dataArray必须是数组类型");

    if (![dataArray isKindOfClass:[NSArray class]]) {
        return;
    }
    self.groupArray = [[NSMutableArray alloc] initWithObjects:dataArray, nil];
}

- (void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    self.cellIdentifier = identifier;
    [super registerClass:cellClass forCellReuseIdentifier:identifier];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.groupArray.count == 0) {//无数据时
        return 1;
    }
    return self.groupArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.groupArray.count == 0) {//无数据时
        return 1;
    }
    
    return [self.groupArray[section] count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.groupArray.count == 0) {//无数据时
        return 300;
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (self.groupArray.count == 0) {//无数据时
        return self.noDataCell;
    }
    
    NSAssert([self.groupArray[indexPath.section] isKindOfClass:[NSArray class]], @"groupArray中的数据必须是数组类型");

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
    
    if (self.groupArray.count > indexPath.section &&
            [self.groupArray[indexPath.section] count]) {
        id dataModel = [self.groupArray[indexPath.section] objectAtIndex:indexPath.row];
        
        //这里的setDataModel：是更新cell数据模型的方法，可自行定义，可参考FCXTableViewCell
        if ([cell respondsToSelector:@selector(setDataModel:)]) {
            [cell performSelectorOnMainThread:@selector(setDataModel:) withObject:dataModel waitUntilDone:NO];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.groupArray.count == 0) {//无数据时
        return;
    }
    NSAssert([self.groupArray[indexPath.section] isKindOfClass:[NSArray class]], @"groupArray中的数据必须是数组类型");

    if (self.groupArray.count > indexPath.section &&
        [self.groupArray[indexPath.section] count] > indexPath.row &&
        self.didSelectRowBlock) {
        
        self.didSelectRowBlock(indexPath, [self.groupArray[indexPath.section] objectAtIndex:indexPath.row]);
    }
}


#pragma mark - 无数据时显示的cell
- (UITableViewCell *)noDataCell {
    if (!_noDataCell) {
        _noDataCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        _noDataCell.selectionStyle = UITableViewCellSelectionStyleNone;

        FCXNoDataView *view = [[self.noDataViewClass alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300)];
        [_noDataCell addSubview:view];
        
        __weak typeof(self) weakSelf = self;
        view.noDataActionBlock = ^(){
            if (weakSelf.noDataActionBlock) {
                weakSelf.noDataActionBlock();
            }
        };
    }
    return _noDataCell;
}

- (Class)noDataViewClass {
    if (!_noDataViewClass) {
        _noDataViewClass = [FCXNoDataView class];
    }
    return _noDataViewClass;
}

@end
