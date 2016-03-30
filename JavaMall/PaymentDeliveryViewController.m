//
//  PaymentDeliveryViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "PaymentDeliveryViewController.h"
#import "UIColor+HexString.h"

@interface PaymentDeliveryViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
- (IBAction)back:(id)sender;

@end

@implementation PaymentDeliveryViewController{
    UILabel *priceLabel;
    UIView *paymentView;
    UIView *shippingView;
}
@synthesize headerView,scrollView;
@synthesize paymentArray, shippingArray, payment, shipping;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];    
    scrollView.backgroundColor = [UIColor colorWithHexString:@"#f3f4f6"];
    
    [self initPaymentView];
    [self initShippingView];
    
    //确定
    UIView *okView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 250) / 2, 5, 250, 34)];
    [okButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [okButton addTarget:self action:@selector(OK:) forControlEvents:UIControlEventTouchUpInside];
    [okView addSubview:okButton];
    
    [self.view addSubview:okView];

}

- (void) initPaymentView{
    paymentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, paymentArray.count * 35 + 45)];
    paymentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
    titleLabel.text = @"支付方式";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [paymentView addSubview:titleLabel];
    
    for(int i = 0; i < paymentArray.count; i++){
        NSDictionary *p = [paymentArray objectAtIndex:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 35 + 35 * i, kScreenWidth-70, 30)];
        [button setTitle:[p objectForKey:@"name"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        button.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
        button.layer.borderWidth = 1.0;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3.0;
        button.tag = i;
        [button setImage:[UIImage imageNamed:@"radio_select.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickPayment:) forControlEvents:UIControlEventTouchUpInside];
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        if([[p objectForKey:@"id"] intValue] == [[payment objectForKey:@"id"] intValue]){
            [button setSelected:YES];
        }
        [paymentView addSubview:button];
    }
    
//    UILabel *remarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35 + 35 * paymentArray.count, kScreenWidth - 20, 25)];
//    remarkLabel.text = @"请到网站后台设置参数";
//    remarkLabel.font = [UIFont systemFontOfSize:12];
//    [remarkLabel setTextColor:[UIColor darkGrayColor]];
//    [paymentView addSubview:remarkLabel];
    
    [scrollView addSubview:paymentView];
}

- (void) initShippingView{
    shippingView = [[UIView alloc] initWithFrame:CGRectMake(0, paymentArray.count * 35 + 50, kScreenWidth, shippingArray.count * 35 + 70)];
    shippingView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 25)];
    titleLabel.text = @"配送方式";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [shippingView addSubview:titleLabel];
    
    for(int i = 0; i < shippingArray.count; i++){
        NSDictionary *s = [shippingArray objectAtIndex:i];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(30, 35 + 35 * i, kScreenWidth-70, 30)];
        [button setTitle:[s objectForKey:@"name"] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        button.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        button.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
        button.layer.borderWidth = 1.0;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3.0;
        [button setImage:[UIImage imageNamed:@"radio_select.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(clickShipping:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = i;
        button.imageEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        if([[s objectForKey:@"name"] isEqualToString:[shipping objectForKey:@"name"]]){
            [button setSelected:YES];
        }
        [shippingView addSubview:button];
    }
    
    priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 35 + 35 * shippingArray.count, kScreenWidth - 20, 25)];
    priceLabel.text = [NSString stringWithFormat:@"快递费用：￥%.2f", [[shipping objectForKey:@"price"] doubleValue]];
    priceLabel.font = [UIFont systemFontOfSize:12];
    [priceLabel setTextColor:[UIColor redColor]];
    [shippingView addSubview:priceLabel];
    
    [scrollView addSubview:shippingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) clickPayment:(id)sender{
    NSArray *subviews = paymentView.subviews;
    for (UIView *view in subviews) {
        if([view isKindOfClass:[UIButton class]]){
            UIButton *b = (UIButton *)view;
            [b setSelected:NO];
        }
    }
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    payment = [paymentArray objectAtIndex:button.tag];
}

- (IBAction)clickShipping:(id)sender{
    NSArray *subviews = shippingView.subviews;
    for (UIView *view in subviews) {
        if([view isKindOfClass:[UIButton class]]){
            UIButton *b = (UIButton *)view;
            [b setSelected:NO];
        }
    }
    UIButton *button = (UIButton *)sender;
    [button setSelected:YES];
    shipping = [shippingArray objectAtIndex:button.tag];
    priceLabel.text = [NSString stringWithFormat:@"快递费用：￥%.2f", [[shipping objectForKey:@"price"] doubleValue]];
}

- (IBAction)OK:(id)sender{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:payment, @"payment", shipping, @"shipping", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:nSelectPaymentDelivery object:nil userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
