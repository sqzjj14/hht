//
//  AppDelegate.m
//  JavaMall
//
//  Created by Dawei on 5/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "Defines.h"
#import "Constants.h"
#import <AlipaySDK/AlipaySDK.h>
#import "UPPaymentControl.h"
#import "UnionpayRSA.h"
#import <CommonCrypto/CommonDigest.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //根据屏幕大小，等比例缩放下单界面左侧滑动UI
      //如果是iphone4
    if (kScreenHeight == 480) {
        _autoSizeScaleX = 320/375.2f;
        _autoSizeScaleY = 480/667.2f;
    }
      //iphone5
    else if (kScreenHeight == 568) {
        _autoSizeScaleX = 320/375.2f;
        _autoSizeScaleY = 568/667.2f;
    }
     //iphone6 6plus
    else{
        _autoSizeScaleX = 1;
        _autoSizeScaleY = 1;
    }
    
    
    //设置SVProgressHUD的字体
    [SVProgressHUD setFont:[UIFont fontWithName:@"Helvetica Neue" size:14]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if(AD_ENABLE){
        [self.window setRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"Ad"]];
    }
    
    else{
        if ([self isLogined] == NO) {
            
            [self.window setRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"Login"]];
            }
        else{
            [self.window setRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"Main"]];
        }
    }
//        [self.window setRootViewController:[storyboard instantiateViewControllerWithIdentifier:@"Payment"]];
    
    //向微信注册
    if(![WECHAT_APP_ID isEqualToString:@""]){
        [WXApi registerApp:WECHAT_APP_ID];
    }
    
    return YES;
}
- (BOOL) isLogined{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"username"] isKindOfClass:[NSString class]] && [[defaults objectForKey:@"username"] length] > 0) {
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    if(![WECHAT_APP_ID isEqualToString:@""] && [[url description] containsString:WECHAT_APP_ID]){
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    NSLog(@"openurl:%@", url);
    
    //跳转支付宝钱包进行支付，处理支付结果
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
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
        }];
    }else if(![WECHAT_APP_ID isEqualToString:@""] && [[url description] containsString:WECHAT_APP_ID]){
        return [WXApi handleOpenURL:url delegate:self];
    }else if([url.host containsString:@"uppayresult"]){
        [[UPPaymentControl defaultControl] handlePaymentResult:url completeBlock:^(NSString *code, NSDictionary *data) {
            
            //结果code为成功时，先校验签名，校验成功后做后续处理
            if([code isEqualToString:@"success"]) {
                
                //判断签名数据是否存在
                if(data == nil){
                    [self paymentCallback:0 message:@"订单支付失败！"];
                    return;
                }
                
                [self paymentCallback:1 message:@"订单支付成功！"];
            }
            else if([code isEqualToString:@"fail"]) {
                [self paymentCallback:0 message:@"订单支付失败！"];
            }
            else if([code isEqualToString:@"cancel"]) {
                [self paymentCallback:0 message:@"用户取消支付！"];
            }
        }];
    }
    
    return YES;
}


#pragma 微信
//接收微信支付结果
-(void) onResp:(BaseResp*)resp {
    if([resp isKindOfClass:[PayResp class]]){
        switch (resp.errCode) {
            case WXSuccess:
                [self paymentCallback:1 message:@"订单支付成功！"];
                break;
            case WXErrCodeCommon:
                [self paymentCallback:0 message:@"用户取消支付！"];
                break;
            default:
                [self paymentCallback:0 message:@"订单支付失败！"];
                break;
        }
    }
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
            [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            break;
        case 2:
            [SVProgressHUD setErrorImage:nil];
            [SVProgressHUD showErrorWithStatus:@"订单正在处理中，请您稍后查询订单状态！" maskType:SVProgressHUDMaskTypeBlack];
            [Constants setAction:@"index"];
            [self.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
            break;
    }
}


@end
