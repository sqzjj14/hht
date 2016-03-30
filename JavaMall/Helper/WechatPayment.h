//
//  WechatPayment.h
//  JavaMall
//
//  Created by Dawei on 9/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WechatPayment : NSObject

-(BOOL) init:(NSDictionary *)_order withPayment:(NSDictionary *)payment;

- ( NSMutableDictionary *)pay;

@end
