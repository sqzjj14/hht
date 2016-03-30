//
//  BaseViewController.h
//  JavaMall
//
//  Created by Dawei on 6/17/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "MainTabBarController.h"

@interface BaseViewController : UIViewController

/**
 *  设置StatusBar的背景色
 *
 *  @param color 背景色
 */
-(void) setStatusBarBackgroudColor:(UIColor *)color;

/**
 *  让view显示某一侧的边框
 *
 *  @param view   要设置的view对象
 *  @param top    是否显示上边框
 *  @param left   是否显示左边框
 *  @param bottom 是否显示下边框
 *  @param right  是否显示右边框
 *  @param color  边框颜色
 *  @param width  边框宽度
 */
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width;

- (UIStoryboard *) mainStoryBoard;

- (UIViewController *) controllerFromMainStroryBoard:(NSString *) id;

- (BOOL) isLogined;

/*
 * 更新购物车角标
 */
- (void) updateCartBadge;

@end
