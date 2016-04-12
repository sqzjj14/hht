//
//  ThridCell.h
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ThridCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UIButton *lessBtn;
@property (weak, nonatomic) IBOutlet UITextField *priceTF;
@property (nonatomic,strong)NSString *pid;

- (IBAction)addCount:(id)sender;
- (IBAction)lessCount:(id)sender;
- (IBAction)gotoCar:(id)sender;

@end
