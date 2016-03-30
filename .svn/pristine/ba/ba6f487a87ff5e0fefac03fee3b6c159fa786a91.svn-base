//
//  GoodsDetailViewController.m
//  JavaMall
//
//  Created by Dawei on 6/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"

@interface GoodsDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton *detailButton;
@property (weak, nonatomic) IBOutlet UIButton *paramButton;


- (IBAction)back:(id)sender;
- (IBAction)detail:(id)sender;
- (IBAction)param:(id)sender;

@end

@implementation GoodsDetailViewController

@synthesize goods_id;
@synthesize headerView, navView, webView, detailButton, paramButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    webView.delegate = self;
    
    [self loadUrl:[BASE_URL stringByAppendingFormat:@"/mobile/goods-%d.html", goods_id]];
}

- (void) loadUrl:(NSString *) urlString{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    navView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    [super setBorderWithView:navView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webViewDelegate
- (void)webViewDidFinishLoad:(nonnull UIWebView *)webView {
    [SVProgressHUD dismiss];
}

- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

- (IBAction)detail:(id)sender {
    [detailButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [paramButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self loadUrl:[BASE_URL stringByAppendingFormat:@"/mobile/goods-%d.html", goods_id]];
}

- (IBAction)param:(id)sender {
    [detailButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [paramButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self loadUrl:[BASE_URL stringByAppendingFormat:@"/mobile/goodsattr-%d.html", goods_id]];
}
@end
