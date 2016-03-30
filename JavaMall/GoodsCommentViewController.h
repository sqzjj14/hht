//
//  GoodsCommentViewController.h
//  JavaMall
//
//  Created by Dawei on 6/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GoodsCommentViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource>

@property (assign, nonatomic) int goods_id;

@end
