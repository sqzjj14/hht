//
//  ReceiptViewController.h
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface ReceiptViewController : BaseViewController<UITextFieldDelegate>

@property (strong, nonatomic) NSString *receiptType;
@property (strong, nonatomic) NSString *receiptTitle;
@property (strong, nonatomic) NSString *receiptContent;

@end
