//
//  CheckoutSuccessViewController.m
//  JavaMall
//
//  Created by Dawei on 7/7/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "CheckoutSuccessViewController.h"
#import "UIColor+HexString.h"
#include "Constants.h"

@interface CheckoutSuccessViewController ()<UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *orderNumber;
@property (weak, nonatomic) IBOutlet UILabel *orderAmount;
@property (weak, nonatomic) IBOutlet UILabel *orderPaytype;
@property (weak, nonatomic) IBOutlet UIView *orderNumberView;
@property (weak, nonatomic) IBOutlet UIView *orderAmountView;
@property (weak, nonatomic) IBOutlet UIView *orderPaytypeView;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imageV;
@property (strong,nonatomic) UIImageView *sentImg;
@property (weak, nonatomic) IBOutlet UILabel *lab1;
@property (weak, nonatomic) IBOutlet UILabel *lab2;
@property (weak, nonatomic) IBOutlet UILabel *lab3;
@property (weak, nonatomic) IBOutlet UILabel *lab4;
- (IBAction)finish:(id)sender;
@end

@implementation CheckoutSuccessViewController

@synthesize order, payment;
@synthesize headerView, orderAmountView, orderNumberView, orderPaytypeView;
@synthesize orderNumber, orderAmount, orderPaytype, finishBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    orderNumber.text = [order objectForKey:@"sn"];
    orderAmount.text = [NSString stringWithFormat:@"￥%.2f", [[order objectForKey:@"order_amount"] doubleValue]];
    orderPaytype.text = [payment objectForKey:@"name"];
    
    [finishBtn setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //长按图片保存
    UILongPressGestureRecognizer *longTap = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imglongTapClick:)];
    [_imageV addGestureRecognizer:longTap];
    _imageV.userInteractionEnabled = YES;
    
    if ([_type isEqualToString:@"alipayPerson"]) {
        _imageV.image = [UIImage imageNamed:@"支付宝二维码"];
       // _lab1.text = @"";
        _lab2.text = @"2.开打支付宝钱包－点击右上角""+""－扫一扫";
        _lab3.text = @"3.扫描页面－点击右上角”…”－从相册选取二维码";
        _lab4.text = @"4.填写对应的订单金额并付款";
    }
}
-(void)imglongTapClick:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        
        UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                      
                                      initWithTitle:@"保存图片"
                                      
                                      delegate:self
                                      
                                      cancelButtonTitle:@"取消"
                                      
                                      destructiveButtonTitle:nil
                                      
                                      otherButtonTitles:@"保存二维码到相册",nil];
        
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        
        [actionSheet showInView:self.view];
        
        
        
        UIImageView *img = (UIImageView *)[gesture view];
        
        _sentImg = img;
        
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex

{
    
    if (buttonIndex == 0) {
        
        UIImageWriteToSavedPhotosAlbum(_sentImg.image, self, @selector(imageSavedToPhotosAlbum:didFinishSavingWithError:contextInfo:), nil);
        
    }
    
}
#pragma mark --- UIActionSheetDelegate---

- (void)imageSavedToPhotosAlbum:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    
    NSString *message = @"保存失败";
    
    if (!error) {
        
        message = @"成功保存到相册";
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
        [alert show];
        
        
        
    }else
        
    {
        
        message = [error description];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
        
        [alert show];
        
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:orderNumberView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:orderAmountView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:orderPaytypeView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (IBAction)finish:(id)sender {
    [Constants setAction:@"index"];
    [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:^{
        
    }];
}
@end
