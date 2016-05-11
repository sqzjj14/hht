//
//  MultilevelMenu.m
//  MultilevelMenu
//
//  Created by gitBurning on 15/3/13.
//  Copyright (c) 2015年 BR. All rights reserved.
//

#import "MultilevelMenu.h"
#import "MultilevelTableViewCell.h"
#import "MultilevelCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "Menu.h"
#import "Defines.h"
#import "ChartView.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "ChartModel.h"
#import "UIColor+HexString.h"
#import "Defines.h"
#import "ChartList.h"
#import "AppDelegate.h"


#define kImageDefaultName @"tempShop"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"//CollectionHeader
#define kMultilevelTableViewCell @"MultilevelTableViewCell"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface MultilevelMenu()

@property(strong,nonatomic) UIView *slideView;
@property(strong,nonatomic) UIView *chartBgView;
@property(strong,nonatomic ) UITableView * leftTablew;
@property(strong,nonatomic ) UICollectionView * rightCollection;
@property(strong,nonatomic) SecondTableView *SecondView;//第二个table
@property(strong,nonatomic) ChartView *chartview;
@property(strong,nonatomic) UIImageView *checkBgimageView;
@property(strong,nonatomic) UIImageView *slideBgimageView;


@property(assign,nonatomic) CGFloat Wight;
@property(assign,nonatomic) CGFloat Height;

//右边侧滑手势
@property (nonatomic,strong) UIPanGestureRecognizer *rightPan;
@property (nonatomic,strong) UIPanGestureRecognizer *leftPan;

//记录选择的是哪个buttn
@property(assign,nonatomic) NSInteger btnTag;
//@property (assign,nonatomic) CGRect frame;
@property(assign,nonatomic) BOOL isReturnLastOffset;

//屏幕比例系数
@property(assign,nonatomic) CGFloat scaleX;
@property(assign,nonatomic) CGFloat scaleY;
//二级的高度
@property(assign,nonatomic) CGFloat secondHight;
//三级动态高度
@property(assign,nonatomic) CGFloat thirdHight;

@end
@implementation MultilevelMenu{
    HttpClient *client;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */
-(id)initWithFrame:(CGRect)frame WithData:(NSArray *)data withSelectIndex:(void (^)(NSInteger, NSInteger, id))selectIndex{
    
    //获取各种屏幕的比例
    AppDelegate *appdele = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    _scaleX = appdele.autoSizeScaleX;
    _scaleY = appdele.autoSizeScaleY;
    
    if (self  == [super initWithFrame:frame]) {
        if (data.count==0) {
            return nil;
        }
        
        _block=selectIndex;
        self.leftSelectColor=[UIColor redColor];
        self.leftSelectBgColor=[UIColor whiteColor];
        self.leftBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftSeparatorColor=UIColorFromRGB(0xE5E5E5);
        self.leftUnSelectBgColor=UIColorFromRGB(0xF3F4F6);
        self.leftUnSelectColor=[UIColor blackColor];
        
        _selectIndex=0;
        _allData = [[NSMutableArray alloc]initWithArray:data];
        _locationArr = data;
        _Height = frame.size.height;
        _Wight = frame.size.width;
        //左view
        self.slideView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,kLeftWidth * _scaleX,frame.size.height)];
        self.slideView.backgroundColor =[UIColor whiteColor];
        //[self addSubview:self.slideView];
        //创建手势
        _leftPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(leftslide:)];
        _leftPan.minimumNumberOfTouches = 1;
        _leftPan.maximumNumberOfTouches = 2;
        [_slideView addGestureRecognizer:_leftPan];
        _rightPan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(rightslide:)];
        _rightPan.minimumNumberOfTouches = 1;
        _rightPan.maximumNumberOfTouches = 2;
       
        //chart底视图
        self.chartBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        
        //引导图
        self.checkBgimageView = [[UIImageView alloc]initWithFrame:CGRectMake(90, 30, 200, 200)];
        self.checkBgimageView.image = [UIImage imageNamed:@"check"];
        self.slideBgimageView = [[UIImageView alloc]initWithFrame:CGRectMake(90,frame.size.height - 200 , 200, 200)];
        self.slideBgimageView.image = [UIImage imageNamed:@"slide"];
        
        //chart参数
        ChartList *chartlist = [[NSBundle mainBundle]loadNibNamed:@"ChartList" owner:nil options:nil][0];
        chartlist.frame = CGRectMake(0, 0, frame.size.width, 30);
        
        [self addSubview:self.chartBgView];
        //[self.chartBgView addSubview:self.chartBgimageView];
        [self.chartBgView addSubview:chartlist];
        [self.chartBgView addSubview:_checkBgimageView];
        [self.chartBgView addSubview:_slideBgimageView];
        [self.chartBgView addSubview:self.slideView];
        [_chartBgView addGestureRecognizer:_rightPan];
        
        
        //左边四个button
        for (NSInteger i = 0; i<_allData.count; i++) {
            
            Menu *title = _allData[i];
            if (title) {
                
#pragma mark 一级设置
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(2.5 * _scaleX , (2 + i * 50) *_scaleY, (kLeftWidth-6) * _scaleX, 47 * _scaleY);
                
                [btn setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
                //[btn setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
                [btn setTitle:title.meunName forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitle:title.meunName forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
                //阴影设置
                btn.layer.cornerRadius = 5;
                btn.layer.shadowOffset =  CGSizeMake(1, 1);
                btn.layer.shadowOpacity = 0.5;
                btn.layer.shadowColor = [[UIColor colorWithHexString:@"#24A676"]CGColor];
                
                btn.titleLabel.font = [UIFont fontWithName:kFont size:13.f];
                btn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = 10 + i;
                [self.slideView addSubview:btn];
            }
        }
        
#pragma mark 二级设置
        
        self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, (2+ 50 * _allData.count) * _scaleY, kLeftWidth * _scaleX, frame.size.height - (50 * _allData.count) *_scaleY)];
        _secondHight = frame.size.height - (50 * _allData.count) *_scaleY;
        self.leftTablew.dataSource=self;
        self.leftTablew.delegate=self;
        
        self.leftTablew.tableFooterView=[[UIView alloc] init];
        self.leftTablew.backgroundColor=self.leftBgColor;
        if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
            self.leftTablew.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
            self.leftTablew.separatorInset=UIEdgeInsetsZero;
        }
        self.leftTablew.separatorColor=self.leftSeparatorColor;
        
        [self.leftTablew registerNib:[UINib nibWithNibName:@"MultilevelTableViewCell" bundle:nil] forCellReuseIdentifier:@"MultilevelTableViewCell"];
        
         [self.slideView addSubview:self.leftTablew];
                
    }
    return self;
}
//一级btn点击监听
-(void)btnClick:(UIButton *)sender
{
    UIButton*btn1=(UIButton*)[self viewWithTag:10];
    UIButton*btn2=(UIButton*)[self viewWithTag:11];
    UIButton*btn3=(UIButton*)[self viewWithTag:12];
    UIButton*btn4=(UIButton*)[self viewWithTag:13];
    UIButton*btn5=(UIButton*)[self viewWithTag:14];
    UIButton*btn6=(UIButton*)[self viewWithTag:15];
    btn1.selected=NO;
    btn2.selected=NO;
    btn3.selected=NO;
    btn4.selected=NO;
    btn5.selected=NO;
    btn6.selected=NO;
    
    if (sender.tag==10) {
        btn1.selected=YES;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=NO;
        btn5.selected=NO;
        btn6.selected=NO;
        [btn1 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn2 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn3 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn4 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn5 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn6 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
        
    }
    if (sender.tag==11) {
        btn1.selected=NO;
        btn2.selected=YES;
        btn3.selected=NO;
        btn4.selected=NO;
        btn5.selected=NO;
        btn6.selected=NO;
        [btn2 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn1 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn3 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn4 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn5 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn6 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
    }
    if (sender.tag==12) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=YES;
        btn4.selected=NO;
        btn5.selected=NO;
        btn6.selected=NO;
        [btn3 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn2 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn1 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn4 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.2]];
        [btn5 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn6 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
    }
    if (sender.tag == 13) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=YES;
        btn5.selected=NO;
        btn6.selected=NO;
        [btn4 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn2 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn3 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn1 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn5 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn6 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
    }
    if (sender.tag == 14) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=NO;
        btn5.selected=YES;
        btn6.selected=NO;
        [btn5 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn2 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn3 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn1 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn4 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn6 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
    }
    if (sender.tag == 15) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=NO;
        btn5.selected=NO;
        btn6.selected=YES;
        [btn6 setBackgroundColor:[UIColor colorWithHexString:@"#24A676"]];
        [btn2 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn3 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn1 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn4 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        [btn5 setBackgroundColor:[UIColor colorWithRed:60/255.0 green:179/255.0 blue:113/255. alpha:0.3]];
        _btnTag = sender.tag - 10;
    }
    [_allData removeAllObjects];
    _allData = [[NSMutableArray alloc]initWithArray:_locationArr];
    [self.leftTablew reloadData];
    self.needToScorllerIndex = 0;
}

-(void)leftslide:(UIPanGestureRecognizer*)pan{
    NSLog(@"leftPan");
    [_SecondView removeFromSuperview];
    static CGPoint point;
    point = CGPointMake(kLeftWidth/2*_scaleX, _Height/2);
    CGPoint offsetPoint = [pan translationInView:self];
    
   // _slideView.center = CGPointMake(point.x + offsetPoint.x, point.y);
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        if ( offsetPoint.x < 0) {
            _slideView.center = CGPointMake(point.x + offsetPoint.x, point.y);
            if (_slideView.center.x > kLeftWidth/2*_scaleX) {
                _slideView.center = point;
            }
        }
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (_slideView.center.x > (kLeftWidth/2-15)*_scaleX){
            _slideView.center = point;
        }
        else if (_slideView.center.x < (kLeftWidth/2-15)*_scaleX){
            _slideView.center = CGPointMake(-kLeftWidth/2*_scaleX, _Height/2);
        }
    }
}
-(void)rightslide:(UIPanGestureRecognizer*)pan{
    [_SecondView removeFromSuperview];
    
    static CGPoint currentpoint;
    currentpoint = _slideView.center;
    CGPoint point = CGPointMake((-kLeftWidth/2) * _scaleX, _Height/2);
    CGPoint initpoint = CGPointMake((kLeftWidth/2) * _scaleX, _Height/2);
    CGPoint offsetPoint = [pan translationInView:self];
    
    if (pan.state == UIGestureRecognizerStateChanged) {
        if ( offsetPoint.x > 0 && (_slideView.center.x != initpoint.x)) {
            _slideView.center = CGPointMake(point.x + offsetPoint.x, point.y);
            if (_slideView.center.x > (kLeftWidth/2) * _scaleX) {
                _slideView.center = initpoint;
            }
            
         }
        if (offsetPoint.x > 0 && (_slideView.center.x < initpoint.x)) {
            _slideView.center = CGPointMake(currentpoint.x + offsetPoint.x, point.y);
            if (_slideView.center.x > (kLeftWidth/2) * _scaleX) {
                _slideView.center = initpoint;
            }
            
        }
        if ( offsetPoint.x < 0 ) {
            NSLog(@"here");
            _slideView.center = CGPointMake(initpoint.x + offsetPoint.x, initpoint.y);
        }
        
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (_slideView.center.x > (-kLeftWidth/2 +20)* _scaleX){
            _slideView.center = initpoint;
        }
        else if (_slideView.center.x < (-kLeftWidth/2+20)* _scaleX){
            _slideView.center = point;
        }
        if (_slideView.center.x > (kLeftWidth/2 -15)* _scaleX){
            _slideView.center = initpoint;
        }
        else if (_slideView.center.x < (kLeftWidth/2 -15)* _scaleX){
            _slideView.center = point;
        }
    }
}
-(void)setLeftBgColor:(UIColor *)leftBgColor{
    _leftBgColor=leftBgColor;
    self.leftTablew.backgroundColor=leftBgColor;
}

-(void)setLeftSelectBgColor:(UIColor *)leftSelectBgColor{
    
    _leftSelectBgColor=leftSelectBgColor;
    self.rightCollection.backgroundColor=leftSelectBgColor;
    self.backgroundColor=leftSelectBgColor;
}

-(void)setLeftSeparatorColor:(UIColor *)leftSeparatorColor{
    _leftSeparatorColor=leftSeparatorColor;
    self.leftTablew.separatorColor=leftSeparatorColor;
}

#pragma mark---左边的tablew 代理
#pragma mark--deleagte
-(void)setNeedToScorllerIndex:(NSInteger)needToScorllerIndex{
    if (needToScorllerIndex>=0) {

        [self.leftTablew selectRowAtIndexPath:[NSIndexPath indexPathForRow:needToScorllerIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        
        MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[self.leftTablew cellForRowAtIndexPath:[NSIndexPath indexPathForRow:needToScorllerIndex inSection:0]];
        cell.titile.textColor=[UIColor whiteColor];
        cell.bgimage.image = [UIImage imageNamed:@"greenBtn"];
        
        _selectIndex=needToScorllerIndex;
        [self.rightCollection reloadData];        
    }
    _needToScorllerIndex=needToScorllerIndex;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    UIButton*btn1=(UIButton*)[self viewWithTag:10];
    UIButton*btn2=(UIButton*)[self viewWithTag:11];
    UIButton*btn3=(UIButton*)[self viewWithTag:12];
    UIButton*btn4=(UIButton*)[self viewWithTag:13];
    UIButton*btn5=(UIButton*)[self viewWithTag:14];
    UIButton*btn6=(UIButton*)[self viewWithTag:15];
    if (btn1.selected == NO && btn2.selected == NO &&btn3.selected == NO &&btn4.selected == NO && btn5.selected == NO && btn6.selected == NO) {
        return 0; //初次进入不显示二级table
    }
    Menu *title=self.allData[_btnTag];
    return title.nextArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString * Identifier=@"MultilevelTableViewCell";
    MultilevelTableViewCell * cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    
    if (!cell) {
        cell=[[NSBundle mainBundle] loadNibNamed:@"MultilevelTableViewCell" owner:self options:nil][0];
    }
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    Menu * title=self.allData[_btnTag];
    Menu * title2 = title.nextArray[indexPath.row];
    
    cell.titile.text= title2.meunName;
    cell.bgimage.image = [UIImage imageNamed:@"whiteBtn"];
 
    
//    if (indexPath.row==self.selectIndex) {
//        cell.titile.textColor=[UIColor whiteColor];
//       // cell.backgroundColor=self.leftSelectBgColor;
//        //line.backgroundColor=cell.backgroundColor;
//        cell.bgimage.image = [UIImage imageNamed:@"greenBtn"];
//    }else{
    cell.titile.textColor=[UIColor blackColor];
       // cell.backgroundColor=[UIColor colorWithRed:36/255.0 green:166/255.0 blue:118/225.0 alpha:0.1];

       // line.backgroundColor=tableView.separatorColor;
        
   // }
    
    
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins=UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset=UIEdgeInsetsZero;
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50 * _scaleX;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=[UIColor whiteColor];
    //cell.backgroundColor=self.leftSelectBgColor;
    cell.bgimage.image = [UIImage imageNamed:@"greenBtn"];
    _selectIndex=indexPath.row;
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    //创建三级table
    Menu * title=self.allData[_btnTag];
    Menu * title2 = title.nextArray[indexPath.row];
    NSArray *data = title2.nextArray;
    if (data.count > 4) {
        _thirdHight = _secondHight;
    }
    else{
        _thirdHight = data.count * 50 * _scaleY;
    }

#pragma mark 三级设置
    
    [_SecondView removeFromSuperview];//删除原来的table
    _SecondView = [[SecondTableView alloc]initWithFrame:CGRectMake(kLeftWidth * _scaleX,( 50 * _allData.count) * _scaleY, kLeftWidth * _scaleX, _thirdHight) WithData: data withChartDetail:^(Menu* info) {
                NSLog(@"cid=%@",info.ID);
        //删除两个引导图画
        if (_slideBgimageView || _checkBgimageView) {
            [_slideBgimageView removeFromSuperview];
            [_checkBgimageView removeFromSuperview];
        }
        [_chartview removeFromSuperview];//删除原来的chart
            _chartview = [[ChartView alloc]
                            initChartViewWithFrame:CGRectMake(0, 30, _Wight , _Height -30)
                            andData:[self DoWithcid:[NSString stringWithFormat:@"%@",info.ID]]];
        [_SecondView removeFromSuperview];//删除原来的table
         //[self bringSubviewToFront:self.slideView];
        [UIView animateWithDuration:0.3f animations:^{
            self.slideView.frame = CGRectMake(-kLeftWidth * _scaleX, 0, kLeftWidth * _scaleX, _Height);
        } completion:^(BOOL finished) {
            [self.chartBgView addSubview:_chartview];
            [self.chartBgView bringSubviewToFront:_slideView];
        }];
    }];

    [self addSubview:_SecondView];
    [self bringSubviewToFront:_SecondView];

    
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=[UIColor blackColor];
    cell.bgimage.image = [UIImage imageNamed:@"whiteBtn"];
   // UILabel *line=(UILabel*)[cell viewWithTag:100];
   // line.backgroundColor=tableView.separatorColor;
    
  //  cell.backgroundColor=[UIColor colorWithRed:36/255.0 green:166/255.0 blue:118/225.0 alpha:0.1];
;
}

-(NSMutableArray *)DoWithcid:(NSString*)cid{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    NSMutableArray *pidArr = [[NSMutableArray alloc]init];
    
    NSString *param = [NSString stringWithFormat:@"%@",cid];
    NSString *url = [[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!list.do?page=1&sort=buynum_desc&cat=%@",param]stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        client = [[HttpClient alloc]init];
                       NSString *content = [client get:url];
                       //没有分类
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               //[self showNoData];
                               NSLog(@"载入cid失败");
                               return nil;
                           }
                      //找到分类下的商品
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSArray *dataArray = [resultJSON objectForKey:@"data"];
                           //枚举商品的总数，储存为gid数组
                           for (NSDictionary *data in dataArray) {
                               ChartModel *chartmodel = [[ChartModel alloc]init];
                               chartmodel.gid = [data objectForKey:@"goods_id"];
                               NSLog(@"gid=%@",chartmodel.gid);
                               chartmodel.name = [data objectForKey:@"name"];
                               chartmodel.price = [data objectForKey:@"price"];
                               //去gid对应的pid
                               NSString *url = [NSString stringWithFormat:@"http://wap.58hht.com/api/mobile/goods!detail.do?id=%@",chartmodel.gid];
                               NSString *content = [client get:url];
                               NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               NSDictionary *dataDic = [resultJSON objectForKey:@"data"];
                               chartmodel.pid = [dataDic objectForKey:@"product_id"];
                               chartmodel.imageURL = [dataDic objectForKey:@"thumbnail"];
                               chartmodel.limitCount = [dataDic objectForKey:@"packingnum"];
                               chartmodel.height_tree = [dataDic objectForKey:@"height"];
                               chartmodel.width_tree = [dataDic objectForKey:@"crownsize"];
                               chartmodel.potSize = [dataDic objectForKey:@"potradius"];
                               chartmodel.specification = [dataDic objectForKey:@"specification"];
                               
                               
                               NSLog(@"pid=%@",chartmodel.pid);
                               
                               [pidArr addObject:chartmodel];
                           }
    
         return pidArr;
}

                   
                   

#pragma mark---imageCollectionView--------------------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{

    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{

    if (self.allData.count==0) {
                return 0;
    }
    Menu *title=self.allData[self.selectIndex];
    
    return title.nextArray.count;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
//    Menu *title=self.allData[self.selectIndex];
//    NSArray *list;
//    
//    Menu *menu;
//    
//    menu = title.nextArray[indexPath.section];
//    if (menu.nextArray.count>0) {
//        menu = title.nextArray[indexPath.section];
//        list = menu.nextArray;
//        menu = list[indexPath.row];
//    }
    Menu *title = self.allData[self.selectIndex];
    Menu *menu = title.nextArray[indexPath.row];
    void (^select)(NSInteger left,NSInteger right,id info) = self.block;
    select(self.selectIndex, indexPath.row, menu);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    MultilevelCollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:kMultilevelCollectionViewCell forIndexPath:indexPath];
    Menu *title=self.allData[self.selectIndex];
   // NSArray *list;
    Menu *menu;
    
//    menu = title.nextArray[indexPath.section];
//    
//    if (menu.nextArray.count>0) {
//        menu = title.nextArray[indexPath.section];
//        list = menu.nextArray;
//        menu = list[indexPath.row];
//    }
    menu = title.nextArray[indexPath.row];
    
    cell.titile.text = menu.meunName;
    cell.backgroundColor=[UIColor clearColor];
    cell.imageView.backgroundColor=UIColorFromRGB(0xF8FCF8);
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:menu.urlName] placeholderImage:[UIImage imageNamed:kImageDefaultName]];
    return cell;
}

//- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
//    
//    NSString *reuseIdentifier;
//    if ([kind isEqualToString: UICollectionElementKindSectionFooter ]){
//        reuseIdentifier = @"footer";
//    }else{
//        reuseIdentifier = kMultilevelCollectionHeader;
//    }
//    
//    Menu *title=self.allData[self.selectIndex];
//    
//    UICollectionReusableView *view =  [collectionView dequeueReusableSupplementaryViewOfKind :kind   withReuseIdentifier:reuseIdentifier   forIndexPath:indexPath];
//    
//    UILabel *label = (UILabel *)[view viewWithTag:1];
//    label.font=[UIFont systemFontOfSize:15];
//    label.textColor=UIColorFromRGB(0x686868);
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
//        if (title.nextArray.count>0) {
//            Menu *menu;
//            menu = title.nextArray[indexPath.section];
//            label.text = menu.meunName;
//        }else{
//            label.text=@"暂无";
//        }
//    }
//    if ([kind isEqualToString:UICollectionElementKindSectionHeader]){
//        label.text = title.meunName;
//    }
//
//    else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
//        view.backgroundColor = [UIColor lightGrayColor];
//        label.text = [NSString stringWithFormat:@"这是footer:%ld",(long)indexPath.section];
//    }
//    return view;
//}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(60, 90);
}

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={kScreenWidth,20};
    return size;
}


#pragma mark---记录滑动的坐标
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection]) {
        self.isReturnLastOffset=YES;
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:self.rightCollection]) {
        Menu * title=self.allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection]) {
        Menu * title=self.allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
        self.isReturnLastOffset=NO;
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:self.rightCollection] && self.isReturnLastOffset) {
        Menu * title=self.allData[self.selectIndex];
        title.offsetScorller=scrollView.contentOffset.y;
    }
}



#pragma mark--Tools
-(void)performBlock:(void (^)())block afterDelay:(NSTimeInterval)delay{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

@end
