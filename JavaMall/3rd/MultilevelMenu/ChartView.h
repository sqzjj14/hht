//
//  ChartView.h
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"

@interface ChartView : UITableView

@property (nonatomic,assign) NSInteger cid;//分类id
@property (nonatomic,assign) NSInteger pid;//商品id

-(id)initChartViewWithFrame:(CGRect)frame andData:(Menu *)menu;
@end
