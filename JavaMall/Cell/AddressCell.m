//
//  AddressCell.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "AddressCell.h"
#import "UIColor+HexString.h"
#import "Defines.h"

@implementation AddressCell

@synthesize name, mobile, address;
@synthesize headerView, bottomView;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) layoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#eff3f6"];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, bottomView.frame.size.width, 0.5f);
    layer.backgroundColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    [bottomView.layer addSublayer:layer];
}

@end
