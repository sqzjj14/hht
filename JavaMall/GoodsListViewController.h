//
//  GoodsListViewController.h
//  JavaMall
//
//  Created by Dawei on 6/27/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SearchDelegate.h"

@interface GoodsListViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, SearchDelegate>

/**
 *  分类id
 */
@property (assign, nonatomic) int cid;
@property (assign, nonatomic) int brand;
@property (assign, nonatomic) int seckill;
@property (strong, nonatomic) NSString *keyword;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *salesBtn;
@property (weak, nonatomic) IBOutlet UIButton *commentBtn;
@property (weak, nonatomic) IBOutlet UIButton *priceBtn;
@property (weak, nonatomic) IBOutlet UIButton *goodsNewBtn;
- (IBAction)sortClick:(id)sender;
- (IBAction)back:(id)sender;



@end
