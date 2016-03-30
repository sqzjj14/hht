//
//  SpecViewController.h
//  JavaMall
//
//  Created by Dawei on 6/28/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface SpecViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary *product;

- (void) loadData;

@end
