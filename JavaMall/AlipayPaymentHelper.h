//
// Created by Dawei on 8/14/15.
// Copyright (c) 2015 Enation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Defines.h"
#import "Constants.h"
#import "AlipayOrder.h"
#import "DataSigner.h"
#import "APAuthV2Info.h"

@interface AlipayPaymentHelper : NSObject

/**
* 支付宝移动支付
*/
+ (NSString *) generateOrderString:(NSDictionary *)order withPayment:(NSDictionary *)payment;

@end