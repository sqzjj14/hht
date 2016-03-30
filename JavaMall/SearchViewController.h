//
//  SearchViewController.h
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SearchDelegate.h"

@interface SearchViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NSObject<SearchDelegate> *delegate;

@end
