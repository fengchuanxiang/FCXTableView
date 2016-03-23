# FCXTableView

##
在iOS开发的过程中，UITableview是使用频率很高的控件之一，今天写的优化方法不是关于性能优化方面的，主要从为Controller瘦身方面考虑的。在使用tableView的时候不可避免的要谈到tableView的delegate和dataSource两个代理，我们经常会把这两个代理赋给Controller，在Controller里面我们会实现它的几个代理方法，最常见的有以下几个：
```objc
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

```
这里会在Controller里面产生许多不必要的代码，下面就从这两个代理方法入手，来为Controller瘦身.

##delegate、dataSource从Controller中去掉，交给Tableview自己处理
在FCXTableView中将Tableview的delegate、dataSource付给自己.

```objc
- (void)fcx_setUp {
    self.delegate = self;
    self.dataSource = self;
}
```
为了实现相应的代理方法，Tableview必须要拿到数据源，考虑到Tableview有分组和不分组两种情况，这里增加了两个属性，其中dataArray是只有一组的情况（使用dataArray时会自动把dataArray放到一个数组里然后再赋值给groupArray），groupArray是多组时用到的，如果项目中不需要分组情况时groupArray是多余的，但为了考虑兼容问题还是加上了.

```objc
@property (nonatomic, strong) NSMutableArray *groupArray;
@property (nonatomic, strong) NSMutableArray *dataArray;

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
```
###在拿到数据源之后就可以实现代理方法了，后面解释为什么判断self.groupArray.count == 0和setDataModel:.

```objc
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
```

##将数据和Cell关联
在拿到数据源groupArray后要和展示的Cell进行关联，在定义Cell的时候每个Cell加一个dataModel的属性，默认会调用setDataModel:（上面提到的）这个方法，可以在这个方法里进行数据的处理.
```objc
- (void)setDataModel:(NSString *)dataModel {

}
```
##将点击某行Cell的代理方法用Block替代
```objc
@property (nonatomic, copy) FCXDidSelectRowBlock didSelectRowBlock;

_tableView.didSelectRowBlock = ^(NSIndexPath *indexPath, id data) {

};
```
##无数据展示优化
用Tableview展示数据的时候就会遇到没有数据或者网络请求失败等情况，需要给用户展示一个当前的无数据状态（上面提到的self.groupArray.count == 0，这个用来判断无数据情况），好点的做法是在设计的时候这里能够用一个通用的模板展示样式，不过这里支持自定义展示样式并支持无数据状态的点击响应事件（noDataActionBlock用Block方式实现），只需传入你定义展示样式的noDataViewClass即可（具体可参考Demo）.
```objc
@property (nonatomic, strong) Class noDataViewClass;
@property (nonatomic, copy) FCXNoDataActionBlock noDataActionBlock;

_tableView.noDataActionBlock = ^(){

};
```
##下拉刷新、上拉加载更多
自己写了一套下拉刷新、上拉加载更多，只需添加一行代码即可，可以更好的和Tableview结合使用.
- [GitHub连接](https://github.com/fengchuanxiang/RefreshView.git) [https://github.com/fengchuanxiang/RefreshView.git](https://github.com/fengchuanxiang/RefreshView.git)

```objc
[_tableView addHeaderWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {

}];

[_tableView addFooterWithRefreshHandler:^(FCXRefreshBaseView *refreshView) {

}];

```

