//
//  SecondTableView.m
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "SecondTableView.h"
#import "Defines.h"
#import "UIColor+HexString.h"
#import "TwoCell.h"
#import "Menu.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface SecondTableView()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(strong,nonatomic,readonly) NSArray * allData;

@property(strong,nonatomic) UIColor * leftBgColor;
@property(strong,nonatomic) UIColor * leftSeparatorColor;
@end


@implementation SecondTableView

-(id)initWithFrame:(CGRect)frame WithData:(NSArray*)data
   withChartDetail:(void(^)(id info))ChartDetail{
    
    self.leftBgColor= UIColorFromRGB(0xF3F4F6);
    self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
    
    if (self  == [super initWithFrame:frame]) {
        if (data.count==0) {
            return nil;
        }
        _allData = data;
        _block = ChartDetail;
        
        self.tableView=
        [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.tableView.dataSource=self;
        self.tableView.delegate=self;
        
        self.tableView.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.tableView];
        self.tableView.backgroundColor=self.leftBgColor;
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            self.tableView.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            self.tableView.separatorInset=UIEdgeInsetsZero;
        }
        self.tableView.separatorColor=self.leftSeparatorColor;
        
        [self.tableView registerNib:[UINib nibWithNibName:@"TwoCell" bundle:nil] forCellReuseIdentifier:@"TwoCell"];
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
    TwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TwoCell"];
    Menu *menu = _allData[indexPath.row];
    cell.title.text = menu.meunName;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    Menu *menu = _allData[indexPath.row];
    void (^select)(id info) = self.block;
    select(menu);
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

@end
