//
//  MainTabBarController.m
//  JavaMall
//
//  Created by Dawei on 5/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "MainTabBarController.h"
#import "UITabBarItem+CustomBadge.h"
#import "HttpClient.h"

@interface MainTabBarController ()

@end

@implementation MainTabBarController{
    HttpClient *client;
    UILabel *badgeLabel;
    UITabBarItem *homeItem;
    UITabBarItem *categoryItem;
    UITabBarItem *cartItem;
    UITabBarItem *personItem;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    client = [[HttpClient alloc] init];
    
    UITabBar *tabBar = self.tabBar;
    self.selectedIndex = 1;
    
    
    UIImage *bgImage = [UIImage imageNamed:@"tabBar_bg"];
    [tabBar setBackgroundImage:bgImage];
    
    //首页
    homeItem = [tabBar.items objectAtIndex:0];
    [homeItem setImage:[[UIImage imageNamed:@"tabBar_home_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [homeItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [homeItem setSelectedImage:[[UIImage imageNamed:@"tabBar_home_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    homeItem.title = nil;
    
    //分类
    categoryItem = [tabBar.items objectAtIndex:1];
    [categoryItem setImage:[[UIImage imageNamed:@"tabBar_category_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [categoryItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [categoryItem setSelectedImage:[[UIImage imageNamed:@"tabBar_category_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    categoryItem.title = nil;
    
    //购物车
    cartItem = [tabBar.items objectAtIndex:2];
    [cartItem setImage:[[UIImage imageNamed:@"tabBar_cart_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [cartItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [cartItem setSelectedImage:[[UIImage imageNamed:@"tabBar_cart_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    cartItem.title = nil;
    
    
    //我的
    personItem = [tabBar.items objectAtIndex:3];
    [personItem setImage:[[UIImage imageNamed:@"tabBar_person_normal"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [personItem setImageInsets:UIEdgeInsetsMake(5, 0, -5, 0)];
    [personItem setSelectedImage:[[UIImage imageNamed:@"tabBar_person_press"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    personItem.title = nil;
    
    [self checkLogin];
    [self updateCartBadge];
}

/*
 * 检查登录状态
 */
- (void) checkLogin{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/member!isLogin.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self clearLoginInfo];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if(resultJSON == nil || [[resultJSON objectForKey:@"result"] intValue] == 0){
                               [self clearLoginInfo];
                               return;
                           }
                       });
                   });
}

/**
 *  清除登录信息
 */
- (void) clearLoginInfo{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"username"];
    [defaults removeObjectForKey:@"face"];
    [defaults removeObjectForKey:@"level"];
    [defaults synchronize];
}

/*
 * 更新购物车角标
 */
- (void) updateCartBadge{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/cart!count.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self updateCartBadge:0];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([resultJSON objectForKey:@"count"] != nil){
                               [self updateCartBadge:[[resultJSON objectForKey:@"count"] intValue]];
                               return;
                           }
                           [self updateCartBadge:0];
                       });
                   });
}

/*
 * 更新购物车角标
 */
- (void) updateCartBadge:(int) _count{
    if (_count <= 0) {
        if(badgeLabel != nil){
            badgeLabel.hidden = YES;
        }
        return;
    }
    if(badgeLabel == nil){
        UIView *v = [cartItem valueForKey:@"view"];
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45 * (v.frame.size.width / 75), 5, 25, 14)];
        [badgeLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:12]];
        [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
        [badgeLabel setBackgroundColor:[UIColor whiteColor]];
        [badgeLabel setTextColor:[UIColor redColor]];
        [badgeLabel setTextAlignment:NSTextAlignmentCenter];
        badgeLabel.layer.cornerRadius = 6;
        badgeLabel.layer.masksToBounds = YES;
        [v addSubview:badgeLabel];
        
        return;
    }
    [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
    badgeLabel.hidden = NO;
}

- (void) viewWillAppear:(BOOL)animated{
    [self updateCartBadge];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
