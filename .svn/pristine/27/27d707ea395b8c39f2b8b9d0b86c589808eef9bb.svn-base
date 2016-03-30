//
//  PaymentViewController.m
//  JavaMall
//
//  Created by Dawei on 8/6/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "PaymentViewController.h"
#import "UIColor+HexString.h"
#import "Constants.h"
#import "SVProgressHUD.h"
#import "AlipayPaymentHelper.h"
#import "AlipaySDK/AlipaySDK.h"
#import "OrderDetailViewController.h"
#import "HttpClient.h"
#import "WechatPayment.h"
#import "WXApiObject.h"
#import "WXApi.h"
#import "UPPaymentControl.h"

#define kMode_Development             @"00"

@interface PaymentViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *orderAmountView;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;

- (IBAction)viewOrder:(id)sender;
- (IBAction)back:(id)sender;

@end

@implementation PaymentViewController{
    NSDictionary *payment;
    
    UIView *payView;
    UIImageView *payImage;
    UILabel *payLabel;
    
}

@synthesize order, paymentid;
@synthesize headerView, orderAmountView, orderAmount;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    orderAmount.text = [NSString stringWithFormat:@"%.2f元", [[order objectForKey:@"order_amount"] doubleValue]];
    
    payView = [[UIView alloc] initWithFrame:CGRectMake(0, 110, kScreenWidth, 40)];
    payImage = [[UIImageView alloc] initWithFrame:CGRectMake(15, 8, 24, 24)];
    [payView addSubview:payImage];
    
    payLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 5, 200, 30)];
    payLabel.textColor = [UIColor darkGrayColor];
    payLabel.font = [UIFont systemFontOfSize:14];
    [payView addSubview:payLabel];
    
    UIImageView *arrow = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth-25, 12.5, 9, 15)];
    arrow.image = [UIImage imageNamed:@"jshop_list_back"];
    [payView addSubview:arrow];
    [self setBorderWithView:payView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [self.view addSubview:payView];
    
    
    [self loadPayment];
}

/**
* 获取支付类型详情
*/
- (void) loadPayment{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    HttpClient *client = [[HttpClient alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/order!payment.do?id=%d", paymentid]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                    if([content length] == 0){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入支付方式失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        return;
                    }

                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                    payment = [result objectForKey:@"data"];
                    if(payment == nil){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入支付方式失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        return;
                    }
                    
                    //设置支付类型及事件
                    NSString *type = [payment objectForKey:@"type"];
                    if([type isEqualToString:@"alipayMobilePlugin"]){
                        UITapGestureRecognizer *alipayTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(alipay:)];
                        [alipayTapGesture setNumberOfTapsRequired:1];
                        [payView addGestureRecognizer:alipayTapGesture];
                        payImage.image = [UIImage imageNamed:@"alipay.png"];
                        payLabel.text = @"支付宝";
                        
                    }else if([type isEqualToString:@"wechatMobilePlugin"]){
                        UITapGestureRecognizer *wechatTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wechat:)];
                        [wechatTapGesture setNumberOfTapsRequired:1];
                        [payView addGestureRecognizer:wechatTapGesture];
                        payImage.image = [UIImage imageNamed:@"wechat.png"];
                        payLabel.text = @"微信支付";
                    }else if([type isEqualToString:@"unionpayMobilePlugin"]){
                        UITapGestureRecognizer *unionpayTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(unionpay:)];
                        [unionpayTapGesture setNumberOfTapsRequired:1];
                        [payView addGestureRecognizer:unionpayTapGesture];
                        payImage.image = [UIImage imageNamed:@"unionpay.png"];
                        payLabel.text = @"银联支付";

                    }

                    
                });
            });
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
    [super setBorderWithView:orderAmountView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

/**
 *  支付宝支付
 *
 *  @param sender
 */
- (IBAction)alipay:(id)sender {
    NSString *orderString = [AlipayPaymentHelper generateOrderString:order withPayment:payment];
    [[AlipaySDK defaultService] payOrder:orderString fromScheme:@"javashop" callback:^(NSDictionary *resultDic) {
        int resultStatus = [[resultDic objectForKey:@"resultStatus"] intValue];
        switch (resultStatus) {
            case 9000:
                [self paymentCallback:1 message:@"订单支付成功！"];
                break;
            case 8000:
                [self paymentCallback:2 message:@"订单正在处理中！"];
                break;
            case 4000:
                [self paymentCallback:0 message:@"订单支付失败！"];
                break;
            case 6001:
                [self paymentCallback:0 message:@"用户取消支付！"];
                break;
            case 6002:
                [self paymentCallback:0 message:@"网络连接出错，请您重试！"];
                break;
            default:
                break;
        }
        NSLog(@"reslut = %@",resultDic);
    }];
}

/**
 *  微信支付
 *
 *  @param sender
 */
- (IBAction)wechat:(id)sender {

    //创建支付签名对象
    WechatPayment *wechatPayment = [[WechatPayment alloc] init];
    [wechatPayment init:order withPayment:payment];

    //获取到实际调起微信支付的参数后，在app端调起支付
    NSMutableDictionary *dict = [wechatPayment pay];

    if(dict == nil){
        [self paymentCallback:0 message:@"订单支付失败！"];
    }else{
        NSMutableString *stamp  = [dict objectForKey:@"timestamp"];

        //调起微信支付
        PayReq* req             = [[PayReq alloc] init];
        req.openID              = [dict objectForKey:@"appid"];
        req.partnerId           = [dict objectForKey:@"partnerid"];
        req.prepayId            = [dict objectForKey:@"prepayid"];
        req.nonceStr            = [dict objectForKey:@"noncestr"];
        req.timeStamp           = stamp.intValue;
        req.package             = [dict objectForKey:@"package"];
        req.sign                = [dict objectForKey:@"sign"];

        [WXApi sendReq:req];
    }
}

/**
 *  银联支付
 *
 *  @param sender
 */
- (IBAction)unionpay:(id)sender {
    [SVProgressHUD showWithStatus:@"支付中..." maskType:SVProgressHUDMaskTypeBlack];
    HttpClient *client = [[HttpClient alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/shop/payment.do?orderid=%d&paymentid=%d", [[order objectForKey:@"order_id"] intValue], paymentid]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           if([content length] == 0){
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"支付失败，请您重试！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           [[UPPaymentControl defaultControl]
                            startPay:content
                            fromScheme:@"javashop"
                            mode:kMode_Development
                            viewController:self];
                       });
                   });
}

/**
* 查看订单
*/
- (IBAction)viewOrder:(id)sender {
    OrderDetailViewController *orderDetailViewController = (OrderDetailViewController *)[super controllerFromMainStroryBoard:@"OrderDetail"];
    orderDetailViewController.orderid = [[order objectForKey:@"order_id"] intValue];
    [self presentViewController:orderDetailViewController animated:YES completion:nil];
}

/**
* 后退
*/
- (IBAction)back:(id)sender {
    [Constants setAction:@"cart"];
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
}

/**
* 处理支付结果
*/
- (void) paymentCallback:(int)result message:(NSString *) msg{
    switch (result){
        case 0:
            [SVProgressHUD setErrorImage:nil];
            [SVProgressHUD showErrorWithStatus:msg maskType:SVProgressHUDMaskTypeBlack];
            break;
        case 1:
            [SVProgressHUD setErrorImage:nil];
            [SVProgressHUD showErrorWithStatus:@"订单支付成功！" maskType:SVProgressHUDMaskTypeBlack];

            [Constants setAction:@"index"];
            [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            break;
        case 2:
            [SVProgressHUD setErrorImage:nil];
            [SVProgressHUD showErrorWithStatus:@"订单正在处理中，请您稍后查询订单状态！" maskType:SVProgressHUDMaskTypeBlack];
            [Constants setAction:@"index"];
            [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            break;
    }
}

@end
