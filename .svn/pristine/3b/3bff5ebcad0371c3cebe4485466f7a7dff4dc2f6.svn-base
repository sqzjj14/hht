//
//  FontHelper.m
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "FontHelper.h"

@implementation FontHelper

+ (CGSize) fontSize:(int)size withString:(NSString *)str{
    NSDictionary *attributeButton = @{NSFontAttributeName: [UIFont systemFontOfSize:size]};
    return [str boundingRectWithSize:CGSizeMake(MAXFLOAT,40) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeButton context:nil].size;
}

@end
