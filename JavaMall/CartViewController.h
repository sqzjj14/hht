//
//  CartViewController.h
//  JavaMall
//
//  Created by Dawei on 6/25/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CartReloadDelegate.h"

@interface CartViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, CartReloadDelegate, UIActionSheetDelegate>
- (IBAction)edit:(id)sender;
- (IBAction)back:(id)sender;

@end
