//
//  OrderDetailViewController.h
//  JavaMall
//
//  Created by Dawei on 7/8/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface OrderDetailViewController : BaseViewController<UIActionSheetDelegate>

@property (assign, nonatomic) int orderid;

@end
