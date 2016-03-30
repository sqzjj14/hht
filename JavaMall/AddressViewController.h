//
//  AddressViewController.h
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface AddressViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate>
@property (nonatomic, strong) NSString *type;
@end
