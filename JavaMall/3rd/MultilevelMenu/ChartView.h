//
//  ChartView.h
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"
#import "ChartModel.h"

@interface ChartView : UITableView

@property(strong,nonatomic,readonly) NSArray * allData;

-(id)initChartViewWithFrame:(CGRect)frame andData:(NSMutableArray *)data;
@end
