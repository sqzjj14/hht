//
//  CouponCell.h
//  JavaMall
//
//  Created by gang liu on 16/4/21.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CouponCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *remark;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UIImageView *image;

@property (nonatomic,copy) NSString *type_id;
@property (nonatomic,copy) NSString *coupon_id;
@property (nonatomic,copy) NSString *price ;
@property (nonatomic,copy) NSString *limitprice;


@end
