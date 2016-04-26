//
//  CouponViewController.h
//  JavaMall
//
//  Created by gang liu on 16/4/21.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponViewController : UIViewController

@property (nonatomic,assign)BOOL ispaying; //是否在支付页面？
@property (nonatomic,copy) NSString *amount;
@property (nonatomic,copy) NSString *couponId;

@end
