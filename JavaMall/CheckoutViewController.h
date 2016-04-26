//
//  CheckoutViewController.h
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface CheckoutViewController : BaseViewController<UITextFieldDelegate>
@property (nonatomic,assign) BOOL isfrist;//是否是刚进入这个页面，处理代金劵问题
- (IBAction)back:(id)sender;

- (void) initCouponView;
@end

