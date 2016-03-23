//
//  FCXTableViewCell.m
//  FCXTableViewDemo
//
//  Created by 冯 传祥 on 16/3/22.
//  Copyright © 2016年 冯 传祥. All rights reserved.
//

#import "FCXTableViewCell.h"

@implementation FCXTableViewCell

- (void)awakeFromNib {
    // Initialization code
}



- (void)setDataModel:(NSString *)dataModel {
    //这里可以进行数据显示的处理
    self.textLabel.text = dataModel;
}


@end
