//
//  Menu.h
//  JavaMall
//
//  Created by Dawei on 6/25/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

/**
 *  菜单图片名
 */
@property(copy,nonatomic) NSString * urlName;
/**
 *  菜单名
 */
@property(copy,nonatomic) NSString * meunName;
/**
 *  菜单ID
 */
@property(copy,nonatomic) NSString * ID;

/**
 *  下一级菜单
 */
@property(strong,nonatomic) NSArray * nextArray;

/**
 *  菜单层数
 */
@property(assign,nonatomic) NSInteger meunNumber;

@property(assign,nonatomic) float offsetScorller;

@end
