//
//  WechatPayment.m
//  JavaMall
//
//  Created by Dawei on 9/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "WechatPayment.h"
#import "WXUtil.h"
#import "ApiXml.h"
#import "Defines.h"
#import "WXApi.h"

@implementation WechatPayment{
    NSString *appid;
    NSString *mchid;
    NSString *apikey;

    NSDictionary *order;
}

//初始化函数
-(BOOL) init:(NSDictionary *)_order withPayment:(NSDictionary *)payment {
    NSDictionary *paramObject = [NSJSONSerialization JSONObjectWithData:[[payment objectForKey:@"config"] dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];

    appid = [paramObject objectForKey:@"appid"];
    mchid = [paramObject objectForKey:@"mchid"];
    apikey = [paramObject objectForKey:@"key"];

    order = _order;

    return YES;
}

//创建package签名
-(NSString*) createMd5Sign:(NSMutableDictionary*)dict
{
    NSMutableString *contentString  =[NSMutableString string];
    NSArray *keys = [dict allKeys];
    //按字母顺序排序
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //拼接字符串
    for (NSString *categoryId in sortedArray) {
        if (   ![[dict objectForKey:categoryId] isEqualToString:@""]
                && ![categoryId isEqualToString:@"sign"]
                && ![categoryId isEqualToString:@"key"]
                ){
            [contentString appendFormat:@"%@=%@&", categoryId, [dict objectForKey:categoryId]];
        }

    }
    //添加key字段
    [contentString appendFormat:@"key=%@", apikey];
    //得到MD5 sign签名
    NSString *md5Sign =[WXUtil md5:contentString];

    //输出Debug Info
    NSLog(@"MD5签名字符串：\n%@\n\n",contentString);

    return md5Sign;
}

//获取package带参数的签名包
-(NSString *)genPackage:(NSMutableDictionary*)packageParams {
    NSString *sign;
    NSMutableString *reqPars = [NSMutableString string];
    //生成签名
    sign        = [self createMd5Sign:packageParams];
    //生成xml的package
    NSArray *keys = [packageParams allKeys];
    [reqPars appendString:@"<xml>\n"];
    for (NSString *categoryId in keys) {
        [reqPars appendFormat:@"<%@>%@</%@>\n", categoryId, [packageParams objectForKey:categoryId],categoryId];
    }
    [reqPars appendFormat:@"<sign>%@</sign>\n</xml>", sign];

    return [NSString stringWithString:reqPars];
}

//提交预支付
-(NSString *)sendPrepay:(NSMutableDictionary *)prePayParams {
    NSString *prepayid = nil;

    //获取提交支付
    NSString *send      = [self genPackage:prePayParams];

    //输出Debug Info
    NSLog(@"发送的xml:%@\n", send);

    //发送请求post xml数据
    NSData *res = [WXUtil httpSend:@"https://api.mch.weixin.qq.com/pay/unifiedorder" method:@"POST" data:send];

    //输出Debug Info
    NSLog(@"服务器返回：\n%@\n\n",[[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding]);

    XMLHelper *xml  = [[XMLHelper alloc] init];

    //开始解析
    [xml startParse:res];

    NSMutableDictionary *resParams = [xml getDict];

    //判断返回
    NSString *return_code   = [resParams objectForKey:@"return_code"];
    NSString *result_code   = [resParams objectForKey:@"result_code"];
    if ( [return_code isEqualToString:@"SUCCESS"] )
    {
        //生成返回数据的签名
        NSString *sign      = [self createMd5Sign:resParams ];
        NSString *send_sign =[resParams objectForKey:@"sign"] ;

        //验证签名正确性
        if( [sign isEqualToString:send_sign]){
            if( [result_code isEqualToString:@"SUCCESS"]) {
                //验证业务处理状态
                prepayid    = [resParams objectForKey:@"prepay_id"];
                return_code = 0;

                NSLog(@"获取预支付交易标示成功！");
            }
        }else{
            NSLog(@"gen_sign=%@\n   _sign=%@\n",sign,send_sign);
            NSLog(@"服务器返回签名验证错误！！！\n");
        }
    }else{
        NSLog(@"接口返回错误！！！\n");
    }
    
    //保存prepayid，用于下次支付
    if(prepayid != nil){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject: prepayid forKey: [order objectForKey:@"sn"]];
        [defaults synchronize];

    }
    
    return prepayid;
}

//============================================================
// V3V4支付流程模拟实现，只作帐号验证和演示
// 注意:此demo只适合开发调试，参数配置和参数加密需要放到服务器端处理
// 服务器端Demo请查看包的文件
// 更新时间：2015年3月3日
// 负责人：李启波（marcyli）
//============================================================
- ( NSMutableDictionary *)pay {

    //================================
    //预付单参数订单设置
    //================================
    srand( (unsigned)time(0) );
    NSString *noncestr  = [NSString stringWithFormat:@"%d", rand()];
    NSMutableDictionary *packageParams = [NSMutableDictionary dictionary];

    [packageParams setObject: appid             forKey:@"appid"];       //开放平台appid
    [packageParams setObject: mchid             forKey:@"mch_id"];      //商户号
    [packageParams setObject: @"APP-001"        forKey:@"device_info"]; //支付设备号或门店号
    [packageParams setObject: noncestr          forKey:@"nonce_str"];   //随机串
    [packageParams setObject: @"APP"            forKey:@"trade_type"];  //支付类型，固定为APP
    [packageParams setObject:[NSString stringWithFormat:@"订单：%@", [order objectForKey:@"sn"]] forKey:@"body"];        //订单描述，展示给用户
    [packageParams setObject:[NSString stringWithFormat:@"%@/api/shop/s_wechatMobilePlugin_payment-callback.do", BASE_URL] forKey:@"notify_url"];  //支付结果异步通知
    [packageParams setObject: [order objectForKey:@"sn"]           forKey:@"out_trade_no"];//商户订单号
    [packageParams setObject: @"127.0.0.1"    forKey:@"spbill_create_ip"];//发器支付的机器ip
    [packageParams setObject: [NSString stringWithFormat:@"%.0f", [[order objectForKey:@"order_amount"] doubleValue] * 100]       forKey:@"total_fee"];       //订单金额，单位为分
//    [packageParams setObject: @"1"       forKey:@"total_fee"];       //订单金额，单位为分

    //获取prepayId（预支付交易会话标识）
    NSString *prePayid;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    prePayid = [defaults objectForKey:[order objectForKey:@"sn"]];
    
    if(prePayid == nil){
        prePayid = [self sendPrepay:packageParams];
    }

    if (prePayid != nil) {
        //获取到prepayid后进行第二次签名

        NSString    *package, *time_stamp, *nonce_str;
        //设置支付参数
        time_t now;
        time(&now);
        time_stamp  = [NSString stringWithFormat:@"%ld", now];
        nonce_str	= [WXUtil md5:time_stamp];
        //重新按提交格式组包，微信客户端暂只支持package=Sign=WXPay格式，须考虑升级后支持携带package具体参数的情况
        //package       = [NSString stringWithFormat:@"Sign=%@",package];
        package         = @"Sign=WXPay";
        //第二次签名参数列表
        NSMutableDictionary *signParams = [NSMutableDictionary dictionary];
        [signParams setObject: appid        forKey:@"appid"];
        [signParams setObject: nonce_str    forKey:@"noncestr"];
        [signParams setObject: package      forKey:@"package"];
        [signParams setObject: mchid        forKey:@"partnerid"];
        [signParams setObject: time_stamp   forKey:@"timestamp"];
        [signParams setObject: prePayid     forKey:@"prepayid"];
        //[signParams setObject: @"MD5"       forKey:@"signType"];
        //生成签名
        NSString *sign  = [self createMd5Sign:signParams];

        //添加签名
        [signParams setObject: sign         forKey:@"sign"];

        NSLog(@"第二步签名成功，sign＝%@\n",sign);

        //返回参数列表
        return signParams;

    }else{
        NSLog(@"获取prepayid失败！\n");
    }
    return nil;
}

@end
