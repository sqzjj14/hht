//
//  BaseViewController.m
//  JavaMall
//
//  Created by Dawei on 6/17/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

/**
 *  设置StatusBar的背景色
 *
 *  @param color 背景色
 */
-(void) setStatusBarBackgroudColor:(UIColor *)color{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0,[UIScreen mainScreen].bounds.size.width, 20)];
    view.backgroundColor = color;
    [self.view addSubview:view];
}

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
- (void)setBorderWithView:(UIView *)view top:(BOOL)top left:(BOOL)left bottom:(BOOL)bottom right:(BOOL)right borderColor:(UIColor *)color borderWidth:(CGFloat)width{
    if (top) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (left) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (bottom) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(0, view.frame.size.height - width, view.frame.size.width, width);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
    if (right) {
        CALayer *layer = [CALayer layer];
        layer.frame = CGRectMake(view.frame.size.width - width, 0, width, view.frame.size.height);
        layer.backgroundColor = color.CGColor;
        [view.layer addSublayer:layer];
    }
}

/*
 * 获取MainStoryBoard
 */
- (UIStoryboard *) mainStoryBoard{
    return [UIStoryboard storyboardWithName:@"Main" bundle:nil];
}

/**
 * 根据id获取StoryBoard中的ViewController
 */
- (UIViewController *) controllerFromMainStroryBoard:(NSString *) id{
    return [[self mainStoryBoard] instantiateViewControllerWithIdentifier:id];
}

/**
 * 是否已登录
 */
- (BOOL) isLogined{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults objectForKey:@"username"] isKindOfClass:[NSString class]] && [[defaults objectForKey:@"username"] length] > 0) {
        return YES;
    }
    return NO;
}

/*
 * 更新购物车角标
 */
- (void) updateCartBadge{
    MainTabBarController *mainTabBarController = (MainTabBarController *)[self tabBarController];
    if(mainTabBarController == nil)
        return;
    [mainTabBarController updateCartBadge];
}

@end
