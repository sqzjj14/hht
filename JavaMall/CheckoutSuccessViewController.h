//
//  CheckoutSuccessViewController.h
//  JavaMall
//
//  Created by Dawei on 7/7/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CheckoutSuccessViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *order;
@property (nonatomic, strong) NSDictionary *payment;

@end
