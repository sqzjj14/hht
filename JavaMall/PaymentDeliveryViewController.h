//
//  PaymentDeliveryViewController.h
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface PaymentDeliveryViewController : BaseViewController
@property (strong, nonatomic) NSArray *paymentArray;
@property (strong, nonatomic) NSArray *shippingArray;
@property (strong, nonatomic) NSDictionary *payment;
@property (strong, nonatomic) NSDictionary *shipping;
@end
