//
//  ThridCell.m
//  JavaMall
//
//  Created by gang liu on 16/4/11.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "ThridCell.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"

@implementation ThridCell{
    NSInteger _count;
    UILabel *badgeLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [_priceTF setBackground:[UIImage imageNamed:@"syncart_middle_btn_enable"]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)addCount:(id)sender {
    _count = [_priceTF.text intValue];
    _priceTF.text = [NSString stringWithFormat:@"%d",_count+1];
}

- (IBAction)lessCount:(id)sender {
    _count = [_priceTF.text intValue];
    if (_count > 1) {
        _priceTF.text = [NSString stringWithFormat:@"%d",_count-1];
    }
}


- (IBAction)gotoCar:(id)sender {
    [SVProgressHUD showWithStatus:@"正在加入购物车..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *content = @"";
        HttpClient *client = [[HttpClient alloc]init];
        NSInteger pid = [_pid intValue];
        _count = [_priceTF.text intValue];
       
        content = [client get:[BASE_URL stringByAppendingFormat:
                               @"/api/mobile/cart!add.do?productid=%d&num=%d",pid,_count]];
        NSLog(@"%@",content);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [SVProgressHUD dismiss];
            
            if([content length] == 0){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"添加到购物车失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                return;
            }
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
            if([[result objectForKey:@"result"] intValue] == -1){
                [SVProgressHUD setErrorImage:nil];
                [SVProgressHUD showErrorWithStatus:@"添加到购物车失败！" maskType:SVProgressHUDMaskTypeBlack];
                return;
            }
            
            if([[result objectForKey:@"result"] intValue] == 0){
                [SVProgressHUD setErrorImage:nil];
                [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                return;
            }
            [SVProgressHUD setInfoImage:nil];
            [SVProgressHUD showInfoWithStatus:@"添加到购物车成功！" maskType:SVProgressHUDMaskTypeBlack];
            [self loadCartCount];
        });
    });
    
}

/*
 * 载入购物车数量
 */
- (void) loadCartCount{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                    HttpClient *client = [[HttpClient alloc]init];
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/cart!count.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self updateCartBadge:0];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([resultJSON objectForKey:@"count"] != nil){
                               [self updateCartBadge:[[resultJSON objectForKey:@"count"] intValue]];
                               return;
                           }
                           [self updateCartBadge:0];
                       });
                   });
    
}

/*
 * 更新购物车角标
 */
- (void)updateCartBadge:(int)_carCount{
    if (_carCount <= 0) {
        if(badgeLabel != nil){
            badgeLabel.hidden = YES;
        }
        return;
    }
    if(badgeLabel == nil){
        //购物车角标
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 20, 14)];
        [badgeLabel setFont:[UIFont systemFontOfSize:12]];
        [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
        [badgeLabel setBackgroundColor:[UIColor redColor]];
        [badgeLabel setTextColor:[UIColor whiteColor]];
        [badgeLabel setTextAlignment:NSTextAlignmentCenter];
        badgeLabel.layer.cornerRadius = 6;
        badgeLabel.layer.masksToBounds = YES;
     //   [cartBtn addSubview:badgeLabel];
        return;
    }
    [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
    badgeLabel.hidden = NO;
}

@end
