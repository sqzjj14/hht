//
//  SecondViewController.m
//  JavaMall
//
//  Created by Dawei on 5/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//


#import "CategoryViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "Menu.h"
#import "MultilevelMenu.h"
#import "CartViewController.h"
#import "HttpClient.h"
#import "GoodsListViewController.h"
#import "SearchViewController.h"

@interface CategoryViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@end

@implementation CategoryViewController

@synthesize headerView, searchView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.automaticallyAdjustsScrollViewInsets = NO;
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];

    
    //tap手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchEvent:)];
    [tapGesture setNumberOfTapsRequired:1];
    
    //搜索框设置
    searchView.layer.borderColor = [UIColor colorWithHexString:@"#dbdbdb"].CGColor;
    searchView.layer.borderWidth = 1.0;
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    searchView.userInteractionEnabled = YES;
    [searchView addGestureRecognizer:tapGesture];
    
    //载入分类
    HttpClient *client = [[HttpClient alloc] init];
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/goodscat!list.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"载入分类失败！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                               [alert show];
                               return;
                           }
                           
                           NSError *error = nil;
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
                           
                           NSMutableArray *categoryArray = [NSMutableArray arrayWithCapacity:0];
                           
                           
                           NSArray *level1Array = [resultJSON objectForKey:@"data"];
                           for (NSDictionary *level1 in level1Array) {
                               //一级
                               Menu *menu = [[Menu alloc] init];
                               menu.meunName = [level1 objectForKey:@"name"];
                               menu.ID = [level1 objectForKey:@"cat_id"];
                               
                               //二级
                               NSMutableArray *level2MenuArray = [NSMutableArray arrayWithCapacity:0];
                               NSArray *level2Array = [level1 objectForKey:@"children"];
                               if(level2Array != nil && level2Array.count > 0){
                                   for (NSDictionary *level2 in level2Array) {
                                       Menu *menu2 = [[Menu alloc] init];
                                       menu2.meunName = [level2 objectForKey:@"name"];
                                       menu2.urlName = [level2 objectForKey:@"image"];
                                       menu2.ID = [level2 objectForKey:@"cat_id"];
                                       [level2MenuArray addObject:menu2];
                                       
                                       //三级
                                       NSMutableArray *level3MenuArray = [NSMutableArray arrayWithCapacity:0];
                                       NSArray *level3Array = [level2 objectForKey:@"children"];
                                       if(level3Array != nil && level3Array.count > 0){
                                           for (NSDictionary *level3 in level3Array) {
                                               Menu *menu3 = [[Menu alloc] init];
                                               menu3.meunName = [level3 objectForKey:@"name"];
                                               menu3.urlName = [level3 objectForKey:@"image"];
                                               menu3.ID = [level3 objectForKey:@"cat_id"];
                                               [level3MenuArray addObject:menu3];
                                           }
                                       }
                                       menu2.nextArray = level3MenuArray;
                                   }
                               }
                               menu.nextArray = level2MenuArray;
                               [categoryArray addObject:menu];
                           }
                           [self initView:categoryArray];
                           [SVProgressHUD dismiss];
                       });
                   });

}

/**
 *  点击手势
 *
 *  @param gesture
 */
- (void)searchEvent:(UITapGestureRecognizer *)gesture{
    SearchViewController *searchViewController = (SearchViewController *)[super controllerFromMainStroryBoard:@"Search"];
    searchViewController.delegate = self;
    [self presentViewController:searchViewController animated:YES completion:nil];
}

- (void)search:(NSString *)_keyword{
    GoodsListViewController *goodsListViewControler = (GoodsListViewController *)[super controllerFromMainStroryBoard:@"GoodsList"];
    goodsListViewControler.keyword = _keyword;
    [self presentViewController:goodsListViewControler animated:YES completion:nil];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

/**
 *  载入分类视图
 *
 *  @param categoryArray 分类数据
 */
- (void) initView:(NSMutableArray *)categoryArray {
    //初始化分类视图
    
    MultilevelMenu * view=[[MultilevelMenu alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight-49-64) WithData:categoryArray withSelectIndex:^(NSInteger left, NSInteger right,Menu* info) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        GoodsListViewController *goodsListViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodsList"];
        //goodsListViewController.keyword =info.meunName;
        goodsListViewController.cid =[info.ID intValue];
        goodsListViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:goodsListViewController animated:YES];
        
    }];
    
    
    view.needToScorllerIndex = 0;
    //    view.leftSelectColor=[UIColor greenColor];
    //  view.leftSelectBgColor=[UIColor redColor];
    view.isRecordLastScroll = YES;
    [self.view addSubview:view];
     //self.edgesForExtendedLayout=UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
