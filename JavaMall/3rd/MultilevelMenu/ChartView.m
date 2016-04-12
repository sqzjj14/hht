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

@property(strong,nonatomic,readonly) NSArray * allData;
@property(strong,nonatomic) UITableView *chartTableW;
@end


@implementation ChartView

-(id)initChartViewWithFrame:(CGRect)frame andData:(Menu *)menu{
    
    if (self  == [super initWithFrame:frame]) {
        if (menu == nil) {
            return nil;
        }
     
        
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
    return 10;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThridCell"];
   // Menu *menu = _allData[indexPath.row];
    //cell.title.text = menu.meunName;
    
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
