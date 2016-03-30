//
//  UIColor+HexString.h
//  JavaMall
//
//  Created by Dawei on 6/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexString)
+ (CGFloat) colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;
+ (UIColor *) colorWithHexString: (NSString *) hexString;
@end
