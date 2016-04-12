//
//  ChartView.m
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "ChartView.h"
#import "ThridCell.h"

@interface ChartView()<UITableViewDelegate,UITableViewDataSource>


@property(strong,nonatomic) UITableView *chartTableW;
@end


@implementation ChartView

-(id)initChartViewWithFrame:(CGRect)frame andData:(NSMutableArray*)data{
    
    if (self  == [super initWithFrame:frame]) {
        if (data == nil) {
            return nil;
        }
        _allData = data;
        
        self.chartTableW=
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.chartTableW.dataSource= self;
        self.chartTableW.delegate= self;
        
        self.chartTableW.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.chartTableW];
        self.chartTableW.backgroundColor=[UIColor whiteColor];
        if ([self.chartTableW respondsToSelector:@selector(setLayoutMargins:)]) {
            self.chartTableW.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.chartTableW respondsToSelector:@selector(setSeparatorInset:)]) {
            self.chartTableW.separatorInset=UIEdgeInsetsZero;
        }
        self.chartTableW.separatorColor=[UIColor blackColor];
        
        [self.chartTableW registerNib:[UINib nibWithNibName:@"ThridCell" bundle:nil] forCellReuseIdentifier:@"ThridCell"];
    }
    
        
        return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _allData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThridCell"];
   // Menu *menu = _allData[indexPath.row];
    //cell.title.text = menu.meunName;
    ChartModel *chartmodel = _allData[indexPath.row];
    cell.name.text = chartmodel.name;
    cell.price.text = [NSString stringWithFormat:@"价格：%@元",chartmodel.price];
    cell.pid = chartmodel.pid;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   // Menu *menu = _allData[indexPath.row];
   // void (^select)(id info) = self.block;
   // select(menu);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

@end
