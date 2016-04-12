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


#define kImageDefaultName @"tempShop"
#define kMultilevelCollectionViewCell @"MultilevelCollectionViewCell"
#define kMultilevelCollectionHeader   @"CollectionHeader"//CollectionHeader
#define kScreenWidth [UIScreen mainScreen].bounds.size.width

#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface MultilevelMenu()

@property(strong,nonatomic ) UITableView * leftTablew;
@property(strong,nonatomic ) UICollectionView * rightCollection;

//记录选择的是哪个buttn
@property(assign,nonatomic) NSInteger btnTag;
//@property (assign,nonatomic) CGRect frame;
@property(assign,nonatomic) BOOL isReturnLastOffset;

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
       // _frame = frame;
        _allData=data;
        
        
        //左边四个button
        for (NSInteger i = 0; i<_allData.count; i++) {
            
            Menu *title = _allData[i];
            if (title) {
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.frame = CGRectMake(0 , 0 + i * 50, 80, 50);
                
                [btn setTitle:title.meunName forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btn setTitle:title.meunName forState:UIControlStateHighlighted];
                [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                
                btn.titleLabel.font = [UIFont fontWithName:kFont size:13.f];
                btn.titleLabel.textAlignment = NSTextAlignmentCenter;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                btn.tag = 10 + i;
                [self addSubview:btn];
            }
        }
        
        /**
         左边的视图
         */
        self.leftTablew=[[UITableView alloc] initWithFrame:CGRectMake(0, 50 * _allData.count, kLeftWidth, frame.size.height - (50 * _allData.count) )];
        self.leftTablew.dataSource=self;
        self.leftTablew.delegate=self;
        
        self.leftTablew.tableFooterView=[[UIView alloc] init];
        [self addSubview:self.leftTablew];
        self.leftTablew.backgroundColor=self.leftBgColor;
        if ([self.leftTablew respondsToSelector:@selector(setLayoutMargins:)]) {
            self.leftTablew.layoutMargins=UIEdgeInsetsZero;
        }
        if ([self.leftTablew respondsToSelector:@selector(setSeparatorInset:)]) {
            self.leftTablew.separatorInset=UIEdgeInsetsZero;
        }
        self.leftTablew.separatorColor=self.leftSeparatorColor;
        
        
        /**
         右边的视图
         */
        UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumInteritemSpacing=0.f;//左右间隔
        flowLayout.minimumLineSpacing=0.f;
        flowLayout.headerReferenceSize = CGSizeMake(0, 0);
        float leftMargin =0;
        self.rightCollection=[[UICollectionView alloc] initWithFrame:CGRectMake(kLeftWidth+leftMargin,0,kScreenWidth-kLeftWidth-leftMargin*2,frame.size.height) collectionViewLayout:flowLayout];
        
        self.rightCollection.delegate=self;
        self.rightCollection.dataSource=self;
        
        
        UINib *nib=[UINib nibWithNibName:kMultilevelCollectionViewCell bundle:nil];
        
        [self.rightCollection registerNib: nib forCellWithReuseIdentifier:kMultilevelCollectionViewCell];
        
        
       // UINib *header=[UINib nibWithNibName:kMultilevelCollectionHeader bundle:nil];
      //  [self.rightCollection registerNib:header forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kMultilevelCollectionHeader];
        
        [self addSubview:self.rightCollection];
        
        
        self.isReturnLastOffset=YES;
        
        self.rightCollection.backgroundColor=self.leftSelectBgColor;
        
        self.backgroundColor=self.leftSelectBgColor;
        
        
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
    btn1.selected=NO;
    btn2.selected=NO;
    btn3.selected=NO;
    btn4.selected=NO;
    
    if (sender.tag==10) {
        btn1.selected=YES;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=NO;
        _btnTag = sender.tag - 10;
        [self.leftTablew reloadData];
    }
    if (sender.tag==11) {
        btn1.selected=NO;
        btn2.selected=YES;
        btn3.selected=NO;
        btn4.selected=NO;
        _btnTag = sender.tag - 10;
        [self.leftTablew reloadData];
    }
    if (sender.tag==12) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=YES;
        btn4.selected=NO;
        _btnTag = sender.tag - 10;
        [self.leftTablew reloadData];
    }
    if (sender.tag == 13) {
        btn1.selected=NO;
        btn2.selected=NO;
        btn3.selected=NO;
        btn4.selected=YES;
        _btnTag = sender.tag - 10;
        [self.leftTablew reloadData];
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    UIButton*btn1=(UIButton*)[self viewWithTag:10];
    UIButton*btn2=(UIButton*)[self viewWithTag:11];
    UIButton*btn3=(UIButton*)[self viewWithTag:12];
    UIButton*btn4=(UIButton*)[self viewWithTag:13];
    if (btn1.selected == NO && btn2.selected == NO &&btn3.selected == NO &&btn4.selected == NO) {
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
        
        UILabel * label=[[UILabel alloc] initWithFrame:CGRectMake(kLeftWidth-0.5, 0, 0.5, 44)];
        label.backgroundColor=tableView.separatorColor;
        [cell addSubview:label];
        label.tag=100;
    }
    
    
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    
    Menu * title=self.allData[_btnTag];
    Menu * title2 = title.nextArray[indexPath.row];
    
    cell.titile.text= title2.meunName;
    //cell.titile.numberOfLines = 2;
    
    UILabel * line=(UILabel*)[cell viewWithTag:100];
    
    if (indexPath.row==self.selectIndex) {
        cell.titile.textColor=self.leftSelectColor;
        cell.backgroundColor=self.leftSelectBgColor;
        line.backgroundColor=cell.backgroundColor;
    }else{
        cell.titile.textColor=self.leftUnSelectColor;
        cell.backgroundColor=self.leftUnSelectBgColor;
        line.backgroundColor=tableView.separatorColor;
        
    }
    
    
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins=UIEdgeInsetsZero;
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset=UIEdgeInsetsZero;
    }
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=self.leftSelectColor;
    cell.backgroundColor=self.leftSelectBgColor;
    _selectIndex=indexPath.row;
    
    UILabel *line=(UILabel*)[cell viewWithTag:100];
    line.backgroundColor=cell.backgroundColor;
    
    
    [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    self.isReturnLastOffset=NO;
    
    //创建三级table
    Menu * title=self.allData[_btnTag];
    Menu * title2 = title.nextArray[indexPath.row];
    NSArray *data = title2.nextArray;
    
    SecondTableView *SecondView = [[SecondTableView alloc]initWithFrame:CGRectMake(kLeftWidth, 50 * _allData.count, 70, 30 * data.count) WithData: data withChartDetail:^(Menu* info) {
        NSLog(@"cid=%@",info.ID);
        ChartView *chartview = [[ChartView alloc]init];
        chartview.cid = [info.ID intValue];
        
    }];
    [self addSubview:SecondView];
    [self bringSubviewToFront:SecondView];
    
    
    //[self.rightCollection reloadData];
    
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    MultilevelTableViewCell * cell=(MultilevelTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.titile.textColor=self.leftUnSelectColor;
    UILabel *line=(UILabel*)[cell viewWithTag:100];
    line.backgroundColor=tableView.separatorColor;
    
    cell.backgroundColor=self.leftUnSelectBgColor;
}

-(void)DoWithcid:(NSInteger)cid{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *url = [BASE_URL stringByAppendingFormat:@"/api/mobile/goods!list.do?page=1&sort=buynum_desc&cat=％d",cid];
                       NSString *content = [client get:url];
                       //没有分类
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               //[self showNoData];
                               return;
                           }
                      //找到分类下的商品
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSArray *dataArray = [resultJSON objectForKey:@"data"];
                           //枚举商品的总数，储存为pid数组
                           NSMutableArray *pidArr = [[NSMutableArray alloc]init];
                           for (NSDictionary *data in dataArray) {
                               NSString *pid = [data valueForKey:@"goods_id"];
                               [pidArr addObject:pid];                               
                           }
                           
                         });
                   });
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
