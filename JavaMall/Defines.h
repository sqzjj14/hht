//
//  Defines.h
//  JavaMall
//
//  Created by Dawei on 6/25/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//
#import <Foundation/Foundation.h>

#ifndef JavaMall_Defines_h
#define JavaMall_Defines_h

#define BASE_URL @"http://wap.58hht.com"
//#define BASE_URL @"http://192.168.199.240:8080"
#define SHOP_NAME @"花卉通"
#define kUserDefaultsCookie @"JavaMallCookie"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

#define kFont @"Helvetica Neue"
#define kFontBold @"Helvetica Bold"

#define nLogin @"LoginCompletionNotification"
#define nSelectAddress @"SelectAddressCompletionNotification"
#define nEditAddress @"EditAddressCompletionNotification"
#define nSelectPaymentDelivery @"SelectPaymentDeliveryCompletionNotification"
#define nSelectReceipt @"SelectReceiptCompletionNotification"
#define nSubmitOrder @"SubmitOrderCompletionNotification"
#define nChangePassword @"ChangePasswordCompletionNotification"

//微信APP ID设置
#define WECHAT_APP_ID @"wxa21087b9d6d0d635"

//广告设置
#define AD_ENABLE NO
#define AD_ID @"1"

//是否启用手机验证
#define MOBILE_VALIDATION NO

#endif

//
//BOOL To_Index;