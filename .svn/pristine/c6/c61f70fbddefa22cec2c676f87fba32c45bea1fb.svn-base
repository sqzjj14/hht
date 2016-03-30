//
//  FirstViewController.m
//  JavaMall
//
//  Created by Dawei on 5/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "HomeViewController.h"
#import "UIColor+HexString.h"
#import "MJRefresh.h"
#import "GoodsListViewController.h"
#import "SearchViewController.h"
#import "GoodsNavigationViewController.h"
#import "GoodsViewController.h"

@interface HomeViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@end

@implementation HomeViewController{
    NSString *homeJavaScript;
}

@synthesize searchView, webview;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webview.delegate = self;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", BASE_URL, @"/mobile/index.html"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webview loadRequest:request];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#CC0033"]];
    
    //下拉刷新
    __weak UIScrollView *scrollView = self.webview.scrollView;
    scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self.webview reload];
    }];
    
    //搜索框设置
    searchView.layer.borderColor = [UIColor colorWithHexString:@"#be161a"].CGColor;
    searchView.layer.borderWidth = 1.0;
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    //tap手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchEvent:)];
    [tapGesture setNumberOfTapsRequired:1];
    [searchView addGestureRecognizer:tapGesture];
    
    NSString *filePath=[[NSBundle mainBundle] pathForResource:@"home" ofType:@"js"];
    homeJavaScript = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - webViewDelegate
- (void)webViewDidFinishLoad:(nonnull UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:homeJavaScript];
    [self.webview.scrollView.header endRefreshing];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    NSString *protocol = @"app://";
    if ([requestString hasPrefix:protocol]) {
        NSString *requestContent = [requestString substringFromIndex:[protocol length]];
        NSArray *vals = [requestContent componentsSeparatedByString:@"/"];
        if ([vals[0] isEqualToString:@"showgoods"]) {
            [self showGoods:vals[1]];
        }else if([vals[0] isEqualToString:@"showlist"]){
            [self showList:[vals[1] intValue]];
        }else if ([vals[0] isEqualToString:@"changetab"]) {
            [self changeTab:vals[1]];
        }else if ([vals[0] isEqualToString:@"myorder"]) {
            [self myorder];
        }else if ([vals[0] isEqualToString:@"showbrand"]) {
            [self showBrand:[vals[1] intValue]];
        }else if ([vals[0] isEqualToString:@"showseckill"]) {
            [self showSeckill:vals[1] act_id:vals[2]];
        }else if([vals[0] isEqualToString:@"showseckilllist"]){
            [self showSeckillList];
        }else if ([vals[0] isEqualToString:@"showgroupbuy"]) {
            [self showGroupbuy:vals[1] groupbuy_id:vals[2]];
        }
        else {
            [webView stringByEvaluatingJavaScriptFromString:@"alert('未定义操作');"];
        }
        return NO;
    }
    return YES;
}

/**
 * 显示商品详情
 */
- (void) showGoods:(NSString *)goodsid{
    GoodsNavigationViewController *goodsNavigationController = (GoodsNavigationViewController *)[super controllerFromMainStroryBoard:@"GoodsNavigation"];
    goodsNavigationController.goods_id = [goodsid intValue];
    [self presentViewController:goodsNavigationController animated:YES completion:nil];

}

/**
 * 显示秒杀商品详情
 */
- (void) showSeckill:(NSString *)goodsid act_id:(NSString *)act_id{
    GoodsNavigationViewController *goodsNavigationController = (GoodsNavigationViewController *)[super controllerFromMainStroryBoard:@"GoodsNavigation"];
    goodsNavigationController.goods_id = [goodsid intValue];
    goodsNavigationController.act_id = [act_id intValue];
    [self presentViewController:goodsNavigationController animated:YES completion:nil];
}

/**
 * 显示团购商品详情
 */
- (void) showGroupbuy:(NSString *)goodsid groupbuy_id:(NSString *)groupbuy_id{
    GoodsNavigationViewController *goodsNavigationController = (GoodsNavigationViewController *)[super controllerFromMainStroryBoard:@"GoodsNavigation"];
    goodsNavigationController.goods_id = [goodsid intValue];
    goodsNavigationController.groupbuy_id = [groupbuy_id intValue];
    [self presentViewController:goodsNavigationController animated:YES completion:nil];
}

/**
 * 显示分类下的商品列表
 */
- (void) showSeckillList{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GoodsListViewController *goodsListViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodsList"];
    goodsListViewController.seckill = 1;
    goodsListViewController.hidesBottomBarWhenPushed = YES;
    [self presentViewController:goodsListViewController animated:YES completion:nil];
}


/**
* 显示分类下的商品列表
*/
- (void) showList:(int)catid{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GoodsListViewController *goodsListViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodsList"];
    goodsListViewController.cid =catid;
    goodsListViewController.hidesBottomBarWhenPushed = YES;
    [self presentViewController:goodsListViewController animated:YES completion:nil];
}

/**
* 显示品牌下的商品列表
*/
- (void) showBrand:(int) brandid{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GoodsListViewController *goodsListViewController = [storyboard instantiateViewControllerWithIdentifier:@"GoodsList"];
    goodsListViewController.brand = brandid;
    goodsListViewController.hidesBottomBarWhenPushed = YES;
    [self presentViewController:goodsListViewController animated:YES completion:nil];
}

- (void) changeTab:(NSString *)index{
    [self tabBarController].selectedIndex = [index intValue] - 1;
}

- (void) myorder{
    if ([super isLogined] == NO) {
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    [self presentViewController:[super controllerFromMainStroryBoard:@"MyOrder"] animated:YES completion:nil];
}

@end
