//
// Created by Dawei on 8/14/15.
// Copyright (c) 2015 Enation. All rights reserved.
//

#import "AlipayPaymentHelper.h"


@implementation AlipayPaymentHelper

+ (NSString *) generateOrderString:(NSDictionary *)order withPayment:(NSDictionary *)payment{

    NSDictionary *paramObject = [NSJSONSerialization JSONObjectWithData:[[payment objectForKey:@"config"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    NSString *partner = [paramObject objectForKey:@"partner"];
    NSString *seller = [paramObject objectForKey:@"seller_email"];
    NSString *privateKey = [paramObject objectForKey:@"rsa_private"];

    /*
     *生成订单信息及签名
     */
    //将商品信息赋予AlixPayOrder的成员变量
    AlipayOrder *alipayOrder = [[AlipayOrder alloc] init];
    alipayOrder.partner = partner;
    alipayOrder.seller = seller;
    alipayOrder.tradeNO = [order objectForKey:@"sn"]; //订单ID（由商家自行制定）
    alipayOrder.productName = [NSString stringWithFormat:@"网店订单：%@", [order objectForKey:@"sn"]];
    alipayOrder.productDescription = [NSString stringWithFormat:@"订单：%@", [order objectForKey:@"sn"]]; //商品描述
    alipayOrder.amount = [NSString stringWithFormat:@"%.2f", [[order objectForKey:@"order_amount"] doubleValue]]; //商品价格
    alipayOrder.notifyURL = [NSString stringWithFormat:@"%@/api/shop/s_alipayMobilePlugin_payment-callback.do", BASE_URL]; //回调URL

    alipayOrder.service = @"mobile.securitypay.pay";
    alipayOrder.paymentType = @"1";
    alipayOrder.inputCharset = @"utf-8";
    alipayOrder.itBPay = @"30m";
    alipayOrder.showUrl = @"m.alipay.com";

    //将商品信息拼接成字符串
    NSString *orderSpec = [alipayOrder description];
    NSLog(@"orderSpec = %@",orderSpec);

    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
    NSString *signedString = [signer signString:orderSpec];

    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;
    if (signedString != nil) {
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                                                 orderSpec, signedString, @"RSA"];
    }
    return orderString;
}
@end