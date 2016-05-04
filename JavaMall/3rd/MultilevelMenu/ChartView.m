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
#import "SVProgressHUD.h"
#import "imageDetailView.h"
#import "Masonry.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface ChartView()<UITableViewDelegate,UITableViewDataSource>


@property(strong,nonatomic) UITableView *chartTableW;
@property(strong,nonatomic) UITapGestureRecognizer *imageTap;
@property(strong,nonatomic) UITapGestureRecognizer *keyboradTap;
//@property(strong,nonatomic) UIImageView *imageView;
@property(strong,nonatomic) imageDetailView *imageView;

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
        
        self.chartTableW.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0,0,self.frame.size.width,10)];
        [self addSubview:self.chartTableW];
        self.chartTableW.backgroundColor= [UIColor whiteColor];
        
//        if ([self.chartTableW respondsToSelector:@selector(setLayoutMargins:)]) {
//            self.chartTableW.layoutMargins=UIEdgeInsetsZero;
//        }
//        if ([self.chartTableW respondsToSelector:@selector(setSeparatorInset:)]) {
//            self.chartTableW.separatorInset=UIEdgeInsetsZero;
//        }
        self.chartTableW.separatorColor=[UIColor clearColor];
        
        [self.chartTableW registerNib:[UINib nibWithNibName:@"ThridCell" bundle:nil] forCellReuseIdentifier:@"ThridCell"];
        //添加取消keyboard手势
        _keyboradTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelKeyborad:)];
        //[self addGestureRecognizer:_keyboradTap];
        
         _imageView = [[NSBundle mainBundle]loadNibNamed:@"imageDetailView" owner:nil options:nil][0];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWasShown:)
         
                                                     name:UIKeyboardWillShowNotification object:nil];
        
        //注册键盘消失的通知
        
        [[NSNotificationCenter defaultCenter] addObserver:self
         
                                                 selector:@selector(keyboardWillBeHidden:)
         
                                                     name:UIKeyboardWillHideNotification object:nil];
    
    }
    
        
        return self;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_allData.count == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"暂无商品，请选择其他分类下单" maskType:SVProgressHUDMaskTypeBlack];
    }
    return _allData.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ThridCell"];
   // Menu *menu = _allData[indexPath.row];
    //cell.title.text = menu.meunName;
    ChartModel *chartmodel = _allData[indexPath.row];
    cell.name.text = chartmodel.name;
    cell.price.text = [NSString stringWithFormat:@"%@",chartmodel.price];
    cell.pid = chartmodel.pid;
    cell.imageURL = chartmodel.imageURL;
    cell.limitCount.text = chartmodel.limitCount;
    cell.height_tree = chartmodel.height_tree;
    cell.width_tree = chartmodel.width_tree;
    cell.potSize = chartmodel.potSize;
    cell.specification.text = chartmodel.specification;
    
    if (indexPath.row%2 == 1) {
        cell.backgroundColor =[UIColor whiteColor];
    }
    else if (indexPath.row%2 == 0){
        cell.backgroundColor = UIColorFromRGB(0xF3F4F6);
    }
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //cell.backgroundColor = UIColorFromRGB(0xF3F4F6);
    //_imageView.frame = CGRectMake(90, 90, 180, 239);
    
    if ([cell.imageURL isKindOfClass:[NSNull class]]) {
        return;
    }
    else {
    [_imageView.image sd_setImageWithURL:[NSURL URLWithString:cell.imageURL] placeholderImage:nil];
      _imageView.height_tree.text = cell.height_tree;
      _imageView.width_tree.text = cell.width_tree;
      _imageView.potSize.text = cell.potSize;

    
    _imageView.layer.cornerRadius = 5.f;
    _imageView.layer.shadowOffset = CGSizeMake(1, 1);
    _imageView.layer.shadowOpacity = 0.8;
    _imageView.layer.shadowColor = [[UIColor colorWithHexString:@"#24A676"]CGColor];
    [self addSubview:_imageView];
        [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.equalTo(@180);
            make.height.equalTo(@239);
        }];
    
    //添加取消手势
    _imageTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelImage:)];
    [self addGestureRecognizer:_imageTap];
    //松开手指时 消除选中效果
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    ThridCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

#pragma mark 手势

- (void)keyboardWasShown:(NSNotification*)aNotification

{
    [self addGestureRecognizer:_keyboradTap];

    
}



-(void)keyboardWillBeHidden:(NSNotification*)aNotification

{
    
    
    
}

-(void)cencelKeyborad:(UITapGestureRecognizer *)tap{
   // [[self findFirstResponderBeneathView:self]resignFirstResponder];
    [self endEditing:YES];
    [self removeGestureRecognizer:_keyboradTap];
    [_imageView removeFromSuperview];
    [self removeGestureRecognizer:_imageTap];
    
}
-(void)cencelImage:(UITapGestureRecognizer *)tap{
    [_imageView removeFromSuperview];
    [self removeGestureRecognizer:_imageTap];
}
- (UIView*)findFirstResponderBeneathView:(UIView*)view
{
    // Search recursively for first responder
    for ( UIView *childView in view.subviews ) {
        if ( [childView respondsToSelector:@selector(isFirstResponder)] && [childView isFirstResponder] )
            return childView;
        UIView *result = [self findFirstResponderBeneathView:childView];
        if ( result )
            return result;
    }
    return nil;
}
@end
