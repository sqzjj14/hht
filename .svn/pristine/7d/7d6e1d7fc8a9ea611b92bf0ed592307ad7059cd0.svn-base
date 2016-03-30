//
//  CartCell.m
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "CartCell.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"

@implementation CartCell{
    HttpClient *client;
}

@synthesize selectedBtn, goodsImage, goodsName, goodsCount, goodsPrice;
@synthesize cartReloadDelegate, productid, cartItemId;

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)reduce:(id)sender {
    int count = [goodsCount.text intValue];
    if(count > 1){
        [self updateCount:-1];
        return;
    }
}

- (IBAction)add:(id)sender {
    [self updateCount:1];
}


- (void) updateCount:(int) addCount{
    if(client == nil){
        client = [[HttpClient alloc] init];
    }
    int currentCount = [goodsCount.text intValue];
    [SVProgressHUD showWithStatus:@"正在更新..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/cart!updateNum.do?cartid=%d&num=%d&productid=%d", cartItemId, (currentCount + addCount), productid]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               goodsCount.text = [NSString stringWithFormat:@"%d", currentCount];
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"更新商品数量失败！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD dismiss];
                               goodsCount.text = [NSString stringWithFormat:@"%d", currentCount];
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           [SVProgressHUD dismiss];
                           [cartReloadDelegate reloadCart];
                       });
                   });
}
@end
