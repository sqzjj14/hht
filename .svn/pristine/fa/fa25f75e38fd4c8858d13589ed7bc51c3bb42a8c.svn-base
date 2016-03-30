//
//  GoodsNavigationViewController.m
//  JavaMall
//
//  Created by Dawei on 7/9/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "GoodsNavigationViewController.h"
#import "GoodsViewController.h"
#import "SpecViewController.h"
#import "MSSlidingPanelController.h"

@interface GoodsNavigationViewController ()

@end

@implementation GoodsNavigationViewController{
    MSSlidingPanelController *sideViewController;
}

@synthesize goods_id, act_id, groupbuy_id;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    GoodsViewController *goodsViewController = (GoodsViewController *)[mainStoryBoard instantiateViewControllerWithIdentifier:@"Goods"];
    goodsViewController.goods_id = goods_id;
    goodsViewController.act_id = act_id;
    goodsViewController.groupbuy_id = groupbuy_id;
    goodsViewController.hidesBottomBarWhenPushed = YES;
    
    SpecViewController *specViewController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"Spec"];
    sideViewController = [[MSSlidingPanelController alloc] initWithCenterViewController:goodsViewController andRightPanelController:specViewController];
    [sideViewController setDelegate:goodsViewController];
    [self pushViewController:sideViewController animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
