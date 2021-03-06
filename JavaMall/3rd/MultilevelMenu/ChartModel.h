//
//  ChartModel.h
//  JavaMall
//
//  Created by gang liu on 16/4/12.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChartModel : NSObject

@property (nonatomic,copy)NSString *pid;
@property (nonatomic,copy)NSString *gid;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *single;//单价
@property (nonatomic,copy) NSString *price;
@property (nonatomic,copy) NSString *imageURL;
@property (nonatomic,copy)NSString *limitCount;
@property (nonatomic,copy)NSString *specification;

@property (nonatomic,copy)NSString *height_tree;
@property (nonatomic,copy)NSString *width_tree;
@property (nonatomic,copy)NSString *potSize;
@property (nonatomic,copy)NSString *height_difference;

@end
