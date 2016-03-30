//
//  CartCell.h
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CartReloadDelegate.h"

@interface CartCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *selectedBtn;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImage;
@property (weak, nonatomic) IBOutlet UILabel *goodsName;
@property (weak, nonatomic) IBOutlet UILabel *goodsPrice;
@property (weak, nonatomic) IBOutlet UITextField *goodsCount;
- (IBAction)reduce:(id)sender;
- (IBAction)add:(id)sender;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageLeft;

@property (nonatomic, strong) id<CartReloadDelegate> cartReloadDelegate;
@property (nonatomic, assign) int productid;
@property (nonatomic, assign) int cartItemId;

@end
