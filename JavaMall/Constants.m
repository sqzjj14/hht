//
//  Constants.m
//  JavaMall
//
//  Created by Dawei on 7/7/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "Constants.h"

static NSString* _action;

@implementation Constants

+ (void) setAction:(NSString *) toAction{
    _action = toAction;
}

+ (NSString *) action{
    return _action;
}
@end
