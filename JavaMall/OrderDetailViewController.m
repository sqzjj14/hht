//
//  OrderDetailViewController.m
//  JavaMall
//
//  Created by Dawei on 7/8/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "UIImageView+WebCache.h"
#import "DateHelper.h"
#import "PaymentViewController.h"

@interface OrderDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)back:(id)sender;

@end

@implementation OrderDetailViewController{
    NSDictionary *order;
    NSArray *itemArray;
    
    UIScrollView *scrollView;
    UIView *statusView;
    UIView *addressView;
    UIView *productView;
    UIView *paymentView;
    UIView *receiptView;
    UIView *couponView;
    UIView *amountView;
    UIView *operationView;
    
    UIActionSheet *actionCancelOrder;
    UIActionSheet *actionRogConfirm;
    
    HttpClient *client;
}

@synthesize orderid;
@synthesize headerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    client = [[HttpClient alloc] init];
    
    [self loadOrder];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  载入商品详细信息
 */
- (void) loadOrder{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/order!detail.do?orderid=%d", orderid]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           if([content length] == 0){
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *data = [result objectForKey:@"data"];
                           if(data == nil){
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           order = [data objectForKey:@"order"];
                           itemArray = [order objectForKey:@"itemList"];
                           [self initDetail];
                       });
                   });
}

- (void) initDetail{
    [scrollView removeFromSuperview];
    [operationView removeFromSuperview];
    scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    
    [self initStatus];
    [self initAddress];
    [self initProduct];
    [self initPayment];
    //[self initReceipt];
    [self initCoupon];
    [self initAmount];
    [self.view addSubview:scrollView];
    
    int status = [[order objectForKey:@"status"] intValue];
    if(status == 0 || status == 5){
        [self initOperation];
    }
    
}

- (void) initStatus{
    statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    statusView.backgroundColor = [UIColor whiteColor];
    
    UILabel *statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 100, 20)];
    statusLabel.font = [UIFont systemFontOfSize:16];
    statusLabel.textColor = [UIColor redColor];
    statusLabel.text = [order objectForKey:@"orderStatus"];
    [statusView addSubview:statusLabel];
    
    UILabel *snLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth-210, 10, 200, 20)];
    snLabel.textAlignment = NSTextAlignmentRight;
    snLabel.font = [UIFont systemFontOfSize:14];
    snLabel.textColor = [UIColor darkGrayColor];
    snLabel.text = [NSString stringWithFormat:@"订单号：%@", [order objectForKey:@"sn"] ];
    [statusView addSubview:snLabel];
    
    [super setBorderWithView:statusView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    
    [scrollView addSubview:statusView];
}

- (void) initAddress{
    addressView = [[UIView alloc] initWithFrame:CGRectMake(0, 45, kScreenWidth, 81)];
    [addressView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"address_info_bg.png"]]];
    
    UIImageView *nameImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 20, 14, 14)];
    nameImage.image = [UIImage imageNamed:@"address_name_icon.png"];
    [addressView addSubview:nameImage];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameImage.frame.origin.x + 18, 14, 100, 25)];
    nameLabel.text = [order objectForKey:@"ship_name"];
    nameLabel.font = [UIFont systemFontOfSize:14];
    [nameLabel setTextColor:[UIColor darkGrayColor]];
    [addressView addSubview:nameLabel];
    
    UIImageView *mobileImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 14, 14)];
    mobileImage.image = [UIImage imageNamed:@"address_phone_icon.png"];
    [addressView addSubview:mobileImage];
    
    UILabel *mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(mobileImage.frame.origin.x + 18, 14, 200, 25)];
    mobileLabel.text = [order objectForKey:@"ship_mobile"];
    mobileLabel.font = [UIFont systemFontOfSize:14];
    [mobileLabel setTextColor:[UIColor darkGrayColor]];
    [addressView addSubview:mobileLabel];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 40, kScreenWidth - 40, 35)];
    addressLabel.text = [NSString stringWithFormat:@"%@%@", [order objectForKey:@"shipping_area"], [order objectForKey:@"ship_addr"]];
    addressLabel.numberOfLines = 2;
    addressLabel.font = [UIFont systemFontOfSize:14];
    [addressLabel setTextColor:[UIColor darkGrayColor]];
    [addressView addSubview:addressLabel];

    [scrollView addSubview:addressView];
}

/**
 *  创建商品列表视图
 */
- (void) initProduct{
    productView = [[UIView alloc] initWithFrame:CGRectMake(0, 131, kScreenWidth, itemArray.count * 55)];
    productView.backgroundColor = [UIColor whiteColor];
    for(int i = 0; i < itemArray.count; i++){
        NSDictionary *item = [itemArray objectAtIndex:i];
        
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0, 55 * i, kScreenWidth, 55)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 7, 44, 44)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"image"]]
                     placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
        
        [listView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(62, 5, kScreenWidth - 62 - 70, 35)];
        name.text = [item objectForKey:@"name"];
        name.numberOfLines = 2;
        name.font = [UIFont systemFontOfSize:12];
        [name setTextColor:[UIColor darkGrayColor]];
        [listView addSubview:name];
        
        UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(62, 35, 50, 18)];
        count.text = [NSString stringWithFormat:@"x%d", [[item objectForKey:@"num"] intValue]];
        count.font = [UIFont systemFontOfSize:12];
        [count setTextColor:[UIColor blackColor]];
        [listView addSubview:count];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 73, 18, 65, 18)];
        price.text = [NSString stringWithFormat:@"￥%.2f",[[item objectForKey:@"price"] doubleValue]];
        price.font = [UIFont systemFontOfSize:12];
        [price setTextColor:[UIColor redColor]];
        [listView addSubview:price];
        
        //        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 20, 9, 15)];
        //        arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
        //        [listView addSubview:arrowImage];
        
        if(i != itemArray.count - 1){
            [super setBorderWithView:listView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
        };
        [productView addSubview:listView];
    }
    [super setBorderWithView:productView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [scrollView addSubview:productView];
}

- (void) initPayment{
    paymentView = [[UIView alloc] initWithFrame:CGRectMake(0, 131 + itemArray.count * 55 + 5, kScreenWidth, 56)];
    paymentView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"支付配送";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [paymentView addSubview:titleLabel];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 5, 180, 15)];
    payLabel.text = [order objectForKey:@"payment_name"];
    payLabel.font = [UIFont systemFontOfSize:12];
    payLabel.textAlignment = NSTextAlignmentRight;
    [payLabel setTextColor:[UIColor darkGrayColor]];
    [paymentView addSubview:payLabel];
    
    UILabel *shipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 20, 180, 15)];
    shipLabel.text = [order objectForKey:@"shipping_type"];
    shipLabel.font = [UIFont systemFontOfSize:12];
    shipLabel.textAlignment = NSTextAlignmentRight;
    [shipLabel setTextColor:[UIColor darkGrayColor]];
    [paymentView addSubview:shipLabel];
    
    UILabel *shipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 35, 180, 15)];
    shipPriceLabel.text = [NSString stringWithFormat:@"快递费：￥%.2f", [[order objectForKey:@"shipping_amount"] doubleValue]];
    shipPriceLabel.font = [UIFont systemFontOfSize:12];
    shipPriceLabel.textAlignment = NSTextAlignmentRight;
    [shipPriceLabel setTextColor:[UIColor redColor]];
    [paymentView addSubview:shipPriceLabel];
    [super setBorderWithView:paymentView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    
    [scrollView addSubview:paymentView];

}

/**
 *  创建发票视图
 */
- (void) initReceipt{
    receiptView = [[UIView alloc] initWithFrame:CGRectMake(0, 131 + itemArray.count * 55 + 56 + 5, kScreenWidth, 56)];
    receiptView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"发票信息";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [receiptView addSubview:titleLabel];
    
//    if([order objectForKey:@"receipt"] == nil){
        UILabel *shipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 20, 180, 15)];
        shipLabel.text = @"不开发票";
        shipLabel.font = [UIFont systemFontOfSize:12];
        shipLabel.textAlignment = NSTextAlignmentRight;
        [shipLabel setTextColor:[UIColor darkGrayColor]];
        [receiptView addSubview:shipLabel];

//    }else{
//        UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 5, 80, 15)];
//        payLabel.text = @"纸质发票";
//        payLabel.font = [UIFont systemFontOfSize:12];
//        payLabel.textAlignment = NSTextAlignmentRight;
//        [payLabel setTextColor:[UIColor darkGrayColor]];
//        [receiptView addSubview:payLabel];
//        
//        UILabel *shipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 20, 180, 15)];
//        shipLabel.text = (receipt == nil || [[receipt objectForKey:@"type"] length] == 0) ? @"不开发票" : [receipt objectForKey:@"title"];
//        shipLabel.font = [UIFont systemFontOfSize:12];
//        shipLabel.textAlignment = NSTextAlignmentRight;
//        [shipLabel setTextColor:[UIColor darkGrayColor]];
//        [receiptView addSubview:shipLabel];
//        
//        UILabel *shipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 35, 80, 15)];
//        shipPriceLabel.text = receipt == nil ? @"" : [receipt objectForKey:@"content"];
//        shipPriceLabel.font = [UIFont systemFontOfSize:12];
//        shipPriceLabel.textAlignment = NSTextAlignmentRight;
//        [shipPriceLabel setTextColor:[UIColor darkGrayColor]];
//        [receiptView addSubview:shipPriceLabel];
//    }
    
    
    [super setBorderWithView:receiptView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [scrollView addSubview:receiptView];
}
#pragma mark coupon视图创建
- (void) initCoupon{
    couponView = [[UIView alloc] initWithFrame:CGRectMake(0, 131 + itemArray.count * 55 + 56 + 5, kScreenWidth, 56)];
    couponView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"优惠劵";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [couponView addSubview:titleLabel];
    
    UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 20, 180, 15)];
    couponLabel.text = [order objectForKey:@"coupon_type"];
    couponLabel.font = [UIFont systemFontOfSize:12];
    couponLabel.textAlignment = NSTextAlignmentRight;
    [couponLabel setTextColor:[UIColor darkGrayColor]];
    [couponView addSubview:couponLabel];
    
    [super setBorderWithView:receiptView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [scrollView addSubview:couponView];
}
- (void) initAmount{
    amountView = [[UIView alloc] initWithFrame:CGRectMake(0, 131 + itemArray.count * 55 + 56 * 2 + 10, kScreenWidth, 100 + 20)]; //20是优惠劵view
    amountView.backgroundColor = [UIColor whiteColor];
    
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 70)];
    
    UILabel *amoutTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 3, 100, 20)];
    amoutTitleLabel.text = @"商品总额";
    amoutTitleLabel.font = [UIFont systemFontOfSize:14];
    [amoutTitleLabel setTextColor:[UIColor darkGrayColor]];
    [view1 addSubview:amoutTitleLabel];
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 3, 180, 20)];
    amountLabel.text = [NSString stringWithFormat:@"￥%.2f", [[order objectForKey:@"goods_amount"] doubleValue]];
    amountLabel.font = [UIFont systemFontOfSize:12];
    amountLabel.textAlignment = NSTextAlignmentRight;
    [amountLabel setTextColor:[UIColor redColor]];
    [view1 addSubview:amountLabel];
    
    UILabel *shippingTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 23, 100, 20)];
    shippingTitleLabel.text = @"+ 运费";
    shippingTitleLabel.font = [UIFont systemFontOfSize:14];
    [shippingTitleLabel setTextColor:[UIColor darkGrayColor]];
    [view1 addSubview:shippingTitleLabel];
    UILabel *shippingLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 23, 180, 20)];
    shippingLabel.text = [NSString stringWithFormat:@"￥%.2f", [[order objectForKey:@"shipping_amount"] doubleValue]];
    shippingLabel.font = [UIFont systemFontOfSize:12];
    shippingLabel.textAlignment = NSTextAlignmentRight;
    [shippingLabel setTextColor:[UIColor redColor]];
    [view1 addSubview:shippingLabel];
    [amountView addSubview:view1];
    
    //coupon
    UILabel *couponTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 43, 100, 20)];
    couponTitleLabel.text = @"+ 优惠劵";
    couponTitleLabel.font = [UIFont systemFontOfSize:14];
    [couponTitleLabel setTextColor:[UIColor darkGrayColor]];
    [view1 addSubview:couponTitleLabel];
    UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 43, 180, 20)];
#pragma mark 新加代金劵参数
    couponLabel.text = [NSString stringWithFormat:@"-￥%.2f", [[order objectForKey:@"coupon_amount"] doubleValue]];
    couponLabel.font = [UIFont systemFontOfSize:12];
    couponLabel.textAlignment = NSTextAlignmentRight;
    [couponLabel setTextColor:[UIColor redColor]];
    [view1 addSubview:couponLabel];
    
    [super setBorderWithView:view1 top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(0, 70, kScreenWidth, 50)];
    UILabel *payTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 100, 20)];
    payTitleLabel.text = @"实付款";
    payTitleLabel.font = [UIFont systemFontOfSize:14];
    [payTitleLabel setTextColor:[UIColor darkGrayColor]];
    [view2 addSubview:payTitleLabel];
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 5, 180, 20)];
    payLabel.text = [NSString stringWithFormat:@"￥%.2f", [[order objectForKey:@"order_amount"] doubleValue]];
    payLabel.font = [UIFont systemFontOfSize:12];
    payLabel.textAlignment = NSTextAlignmentRight;
    [payLabel setTextColor:[UIColor redColor]];
    [view2 addSubview:payLabel];
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 23, 180, 20)];
    dateLabel.text = [NSString stringWithFormat:@"下单时间：%@", [DateHelper unixtimeToString:[[order objectForKey:@"create_time"] doubleValue] withFormat:@"yyyy-MM-dd HH:mm:ss"]];
    dateLabel.font = [UIFont systemFontOfSize:12];
    dateLabel.textAlignment = NSTextAlignmentRight;
    [dateLabel setTextColor:[UIColor darkGrayColor]];
    [view2 addSubview:dateLabel];
    
    [amountView addSubview:view2];

    [super setBorderWithView:amountView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [scrollView addSubview:amountView];
}

/*
 * 操作栏
 */
- (void) initOperation{
    operationView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [operationView setBackgroundColor:[UIColor colorWithHexString:@"#303030"]];
    [operationView setAlpha:0.8f];

    if([[order objectForKey:@"status"] intValue] == 0){
        if([[order objectForKey:@"payment_type"] isEqualToString:@"alipayMobilePlugin"] ||
           [[order objectForKey:@"payment_type"] isEqualToString:@"wechatMobilePlugin"] ||
           [[order objectForKey:@"payment_type"] isEqualToString:@"unionpayMobilePlugin"]){
            UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 180, 0, 60, 44)];
            [cancelButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
            [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
            [cancelButton setTitle:@"取消订单" forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
            [operationView addSubview:cancelButton];

            UIButton *payButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 0, 100, 44)];
            [payButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
            [payButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
            [payButton setTitle:@"在线支付" forState:UIControlStateNormal];
            [payButton addTarget:self action:@selector(payment:) forControlEvents:UIControlEventTouchUpInside];
            [operationView addSubview:payButton];
        }else if([[order objectForKey:@"payment_type"] isEqualToString:@"cod"]){
            UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 0, 60, 44)];
            [cancelButton setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
            [cancelButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
            [cancelButton setTitle:@"取消订单" forState:UIControlStateNormal];
            [cancelButton addTarget:self action:@selector(cancelOrder:) forControlEvents:UIControlEventTouchUpInside];
            [operationView addSubview:cancelButton];
        }
    }else if([[order objectForKey:@"status"] intValue] == 5){
        UIButton *rogButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 0, 100, 44)];
        [rogButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
        [rogButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [rogButton setTitle:@"确认收货" forState:UIControlStateNormal];
        [rogButton addTarget:self action:@selector(rogConfirm:) forControlEvents:UIControlEventTouchUpInside];
        [operationView addSubview:rogButton];
        
        UIButton *hurryButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 0, 100, 44)];
        [hurryButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
        [hurryButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [hurryButton setTitle:@"催单" forState:UIControlStateNormal];
        [hurryButton addTarget:self action:@selector(hurryUp:) forControlEvents:UIControlEventTouchUpInside];
        [operationView addSubview:hurryButton];
        
    }
    
    [self.view addSubview:operationView];
}

//催单
- (void)hurryUp:(id)sender{
    [SVProgressHUD setSuccessImage:nil];
    [SVProgressHUD showSuccessWithStatus:@"取消订单成功！" maskType:SVProgressHUDMaskTypeBlack];
}

/*
 * 取消订单
 */
- (void) cancelOrder:(id)sender{
    actionCancelOrder = [[UIActionSheet alloc] initWithTitle:@"您确认要取消此订单吗？"
                                              delegate:self
                                     cancelButtonTitle:@"取消"
                                destructiveButtonTitle:@"确定"
                                     otherButtonTitles:nil
                   ];
    [actionCancelOrder showInView:self.view];
}

/*
 * 确认收货
 */
- (void) rogConfirm:(id)sender{
    actionRogConfirm = [[UIActionSheet alloc] initWithTitle:@"请您确认收到货确再进行此操作，否则会有可能财货两空！"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                     destructiveButtonTitle:@"确定"
                                          otherButtonTitles:nil
                        ];
    [actionRogConfirm showInView:self.view];
}

/**
* 支付订单
*/
- (void) payment:(id)sender{
    PaymentViewController *paymentViewController = (PaymentViewController *) [super controllerFromMainStroryBoard:@"Payment"];
    paymentViewController.order = order;
    paymentViewController.paymentid = [[order objectForKey:@"payment_id"] intValue];
    [self presentViewController:paymentViewController animated:YES completion:nil];
}


-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(actionSheet == actionCancelOrder){
        if(buttonIndex !=[actionSheet cancelButtonIndex]){
            [SVProgressHUD showWithStatus:@"正在取消订单..." maskType:SVProgressHUDMaskTypeBlack];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                               NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/order!cancel.do?sn=%@&reason=", [order objectForKey:@"sn"]]];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [SVProgressHUD dismiss];
                                   
                                   if([content length] == 0){
                                       [SVProgressHUD setErrorImage:nil];
                                       [SVProgressHUD showErrorWithStatus:@"取消订单失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                                       return;
                                   }
                                   
                                   NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                   if([[result objectForKey:@"result"] intValue] == 0){
                                       [SVProgressHUD setErrorImage:nil];
                                       [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                                       return;
                                   }
                                   
                                   [SVProgressHUD setSuccessImage:nil];
                                   [SVProgressHUD showSuccessWithStatus:@"取消订单成功！" maskType:SVProgressHUDMaskTypeBlack];
                                   [self loadOrder];
                               });
                           });
        }
    }else{
        if(buttonIndex !=[actionSheet cancelButtonIndex]){
            [SVProgressHUD showWithStatus:@"正在确认收货..." maskType:SVProgressHUDMaskTypeBlack];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                           ^{
                               NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/order!rogConfirm.do?orderid=%d", [[order objectForKey:@"order_id"]  intValue]]];
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [SVProgressHUD dismiss];
                                   
                                   if([content length] == 0){
                                       [SVProgressHUD setErrorImage:nil];
                                       [SVProgressHUD showErrorWithStatus:@"确认收货失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                                       return;
                                   }
                                   
                                   NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                                   if([[result objectForKey:@"result"] intValue] == 0){
                                       [SVProgressHUD setErrorImage:nil];
                                       [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                                       return;
                                   }
                                   
                                   [SVProgressHUD setSuccessImage:nil];
                                   [SVProgressHUD showSuccessWithStatus:@"确认收货成功！" maskType:SVProgressHUDMaskTypeBlack];
                                   [self loadOrder];
                               });
                           });
        }
    }
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
