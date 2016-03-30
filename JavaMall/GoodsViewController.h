//
//  GoodsViewController.h
//  JavaMall
//
//  Created by Dawei on 6/28/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "ImagePlayerView.h"
#import "MSSlidingPanelController.h"
#import "MWPhotoBrowser.h"

@interface GoodsViewController : BaseViewController<ImagePlayerViewDelegate, MSSlidingPanelControllerDelegate, MWPhotoBrowserDelegate>

@property (assign, nonatomic) int goods_id;

//秒杀活动id
@property (assign, nonatomic) int act_id;

//团购活动id
@property (assign, nonatomic) int groupbuy_id;

- (void) setProduct:(NSDictionary *) _product count:(int) _count;
- (void) addToCart;
- (void) addToCart:(int) _count;
@end
