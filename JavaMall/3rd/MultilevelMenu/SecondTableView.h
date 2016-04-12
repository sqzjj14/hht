//
//  SecondTableView.h
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SecondTableView : UIView

@property(copy,nonatomic,readonly) id block;


-(id)initWithFrame:(CGRect)frame WithData:(NSArray*)data
   withChartDetail:(void(^)(id info))ChartDetail;
@end

