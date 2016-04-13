//
//  ChartView.m
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "ChartView.h"
#import "ThridCell.h"
#import "UIColor+HexString.h"
#import "UIImageView+WebCache.h"
#import "Defines.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ChartView()<UITableViewDelegate,UITableViewDataSource>


@property(strong,nonatomic) UITableView *chartTableW;
@property(strong,nonatomic) UITapGestureRecognizer *imageTap;
@property(strong,nonatomic) UIImageView *imageView;
@end


@implementation ChartView

-(id)initChartViewWithFrame:(CGRect)frame andData:(NSMutableArray*)data{
    
    if (self  == [super initWithFrame:frame]) {
        if (data == nil) {
            return nil;
        }
        _allData = [[NSMutableArray alloc]init];
        [_allData removeAllObjects];
        _allData = data;
        
        self.chartTableW=
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.chartTableW.dataSource= self;
        self.chartTableW.delegate= self;
        
        self.chartTableW.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.chartTableW];
        self.chartTableW.backgroundColor= [UIColor whiteColor];
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
    cell.imageURL = chartmodel.imageURL;
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = UIColorFromRGB(0xF3F4F6);
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(90, 90, kScreenWidth-180, kScreenWidth-180)];
    [_imageView sd_setImageWithURL:[NSURL URLWithString:cell.imageURL] placeholderImage:nil];
    [self addSubview:_imageView];
    //添加取消手势
    _imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelImage:)];
    [self addGestureRecognizer:_imageTap];
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(void)cencelImage:(UITapGestureRecognizer *)tap{
    [_imageView removeFromSuperview];
    [self removeGestureRecognizer:tap];
    
}
@end
