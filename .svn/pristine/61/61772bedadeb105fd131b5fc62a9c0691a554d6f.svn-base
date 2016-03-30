//
//  CheckoutSuccessViewController.m
//  JavaMall
//
//  Created by Dawei on 7/7/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "CheckoutSuccessViewController.h"
#import "UIColor+HexString.h"
#include "Constants.h"

@interface CheckoutSuccessViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;
@property (weak, nonatomic) IBOutlet UILabel *orderPaytype;
@property (weak, nonatomic) IBOutlet UIView *orderNumberView;
@property (weak, nonatomic) IBOutlet UIView *orderAmountView;
@property (weak, nonatomic) IBOutlet UIView *orderPaytypeView;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
- (IBAction)finish:(id)sender;
@end

@implementation CheckoutSuccessViewController

@synthesize order, payment;
@synthesize headerView, orderAmountView, orderNumberView, orderPaytypeView;
@synthesize orderNumber, orderAmount, orderPaytype, finishBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    orderNumber.text = [order objectForKey:@"sn"];
    orderAmount.text = [NSString stringWithFormat:@"￥%.2f", [[order objectForKey:@"order_amount"] doubleValue]];
    orderPaytype.text = [payment objectForKey:@"name"];
    
    [finishBtn setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:orderNumberView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:orderAmountView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:orderPaytypeView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (IBAction)finish:(id)sender {
    [Constants setAction:@"index"];
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:^{
        
    }];
}
@end
