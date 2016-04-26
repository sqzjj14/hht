//
//  CheckoutViewController.m
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "CheckoutViewController.h"
#import "UIColor+HexString.h"
#import "FontHelper.h"
#import "HttpClient.h"
#import "PaymentDeliveryViewController.h"
#import "ReceiptViewController.h"
#import "SVProgressHUD.h"
#import "CheckoutSuccessViewController.h"
#import "UIImageView+WebCache.h"
#import "PaymentViewController.h"
#import "CouponViewController.h"

@interface CheckoutViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@property (nonatomic,strong) NSMutableDictionary *selectCouponDic;
@property (nonatomic,copy) NSString *couponPrice; //优惠劵的里价格！！

@end

@implementation CheckoutViewController{
    HttpClient *client;
    
    UIView *addressView;
    UIView *paymnetView;
    UIView *receiptView;
    UIView *remarkView;
    UIView *couponView;
    UITextField *remarkTextField;
    UILabel *amountLabel;
    
    double amount;
    double shippingPrice;
    
    NSMutableDictionary *address;
    NSArray *shippingArray;
    NSDictionary *shipping;
    NSArray *paymentArray;
    NSDictionary *payment;
    NSMutableDictionary *receipt;
    
    NSMutableArray *products;
}

@synthesize headerView, scrollView;

- (void)viewDidLoad {
    [super viewDidLoad];
    _isfrist = YES;
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    client = [[HttpClient alloc] init];
    
    amount = 0.0f;
    shippingPrice = 0.0f;
    
    //绑定通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectAddressCompletion:) name:nSelectAddress object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectPaymentDeliveryCompletion:) name:nSelectPaymentDelivery object:nil];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectReceiptCompletion:) name:nSelectReceipt object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectCouponCompletion:) name:nSelectCoupon object:nil];
    
    self.scrollView.backgroundColor = [UIColor colorWithHexString:@"#f3f4f6"];
    [self initCheckoutView];
    [self loadDefaultAddress];
    [self initCouponView];
    
    //注册键盘出现与隐藏时候的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboadWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAddressCompletion:) name:nEditAddress object:nil];
    
}

/**
 *  创建结算视图
 */
- (void) initCheckoutView{
    UIView *checkoutView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [checkoutView setBackgroundColor:[UIColor colorWithHexString:@"#303030"]];
    [checkoutView setAlpha:0.8f];
    
    amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 150, 25)];
    amountLabel.text = @"";
    [amountLabel setTextColor:[UIColor whiteColor]];
    [amountLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [checkoutView addSubview:amountLabel];
    
    UIButton *checkoutButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 0, 100, 44)];
    [checkoutButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [checkoutButton setTitle:@"提交订单" forState:UIControlStateNormal];
    [checkoutButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [checkoutButton addTarget:self action:@selector(submitOrder) forControlEvents:UIControlEventTouchUpInside];
    [checkoutView addSubview:checkoutButton];
    
    [self.view addSubview:checkoutView];
}

- (void) updateAmount{
    amountLabel.text = [NSString stringWithFormat:@"实付款:￥%.2f", (amount+shippingPrice)];
}

/*
 * 载入默认收货地址
 */
- (void) loadDefaultAddress{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/address!defaultAddress.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self initAddressView];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [self initAddressView];
                               return;
                           }
                           
                           NSDictionary *data = [result objectForKey:@"data"];
                           if(data == nil){
                               [self initAddressView];
                               return;
                           }
                           if([data objectForKey:@"defaultAddress"] != nil){
                               address = [NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"defaultAddress"]];
                               [self initAddressView];
                           }
                       });
                   });
    
}

/**
 *  创建地址视图
 */
- (void) initAddressView{
    addressView = [[UIView alloc] initWithFrame:CGRectMake(0, 5, kScreenWidth, 81)];
    [addressView setBackgroundColor:[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"address_info_bg.png"]]];
    if(address == nil){
        UIButton *createAddressBtn = [[UIButton alloc] initWithFrame:addressView.frame];
        [createAddressBtn setTitle:@"请新建收货地址以确保商品顺利到达" forState:UIControlStateNormal];
        createAddressBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [createAddressBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [createAddressBtn addTarget:self action:@selector(createAddress) forControlEvents:UIControlEventTouchUpInside];
        [addressView addSubview:createAddressBtn];
    }else{
        UIImageView *nameImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 20, 14, 14)];
        nameImage.image = [UIImage imageNamed:@"address_name_icon.png"];
        [addressView addSubview:nameImage];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameImage.frame.origin.x + 18, 14, 100, 25)];
        nameLabel.text = [address objectForKey:@"name"];
        nameLabel.font = [UIFont systemFontOfSize:12];
        [nameLabel setTextColor:[UIColor darkGrayColor]];
        [addressView addSubview:nameLabel];
        
        UIImageView *mobileImage = [[UIImageView alloc] initWithFrame:CGRectMake(100, 20, 14, 14)];
        mobileImage.image = [UIImage imageNamed:@"address_phone_icon.png"];
        [addressView addSubview:mobileImage];
        
        UILabel *mobileLabel = [[UILabel alloc] initWithFrame:CGRectMake(mobileImage.frame.origin.x + 18, 14, 200, 25)];
        mobileLabel.text = [address objectForKey:@"mobile"];
        mobileLabel.font = [UIFont systemFontOfSize:12];
        [mobileLabel setTextColor:[UIColor darkGrayColor]];
        [addressView addSubview:mobileLabel];
        
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 40, kScreenWidth - 40, 35)];
        addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@", [address objectForKey:@"province"], [address objectForKey:@"city"], [address objectForKey:@"region"], [address objectForKey:@"addr"]];
        addressLabel.numberOfLines = 2;
        addressLabel.font = [UIFont systemFontOfSize:12];
        [addressLabel setTextColor:[UIColor darkGrayColor]];
        [addressView addSubview:addressLabel];
        
        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 33, 9, 15)];
        arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
        [addressView addSubview:arrowImage];
        
        UITapGestureRecognizer *specTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAddress:)];
        [specTapGesture setNumberOfTapsRequired:1];
        [addressView addGestureRecognizer:specTapGesture];

    }
    [self.scrollView addSubview:addressView];
    
    //载入完成默认地址后，开始加载商品信息
    [self loadProducts];
}

- (void) loadProducts{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/cart!list.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self initProductView];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *data = [result objectForKey:@"data"];
                           
                           if(data == nil){
                               [self initProductView];
                               return;
                           }
                           
                           NSArray *goodsList = [data objectForKey:@"goodslist"];
                           if(goodsList == nil || goodsList.count == 0){
                               [self initProductView];
                               return;
                           }
                           //购物车商品
                           products = [NSMutableArray arrayWithArray:goodsList];
                           
                           amount = [[data objectForKey:@"total"] doubleValue];
                           
                           //设置scrollView内容视图
                           scrollView.contentSize = CGSizeMake(kScreenWidth, 325 + products.count * 55);
                           
                           [self initProductView];
                           [self updateAmount];
                       });
                   });
}

/**
 *  创建商品列表视图
 */
- (void) initProductView{
    UIView *productView = [[UIView alloc] initWithFrame:CGRectMake(0, 91, kScreenWidth, products.count * 55)];
    productView.backgroundColor = [UIColor whiteColor];
    for(int i = 0; i < products.count; i++){
        NSDictionary *product = [products objectAtIndex:i];
        
        UIView *listView = [[UIView alloc] initWithFrame:CGRectMake(0, 55 * i, kScreenWidth, 55)];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 7, 44, 44)];
        [imageView sd_setImageWithURL:[NSURL URLWithString:[product objectForKey:@"image_default"]]
                      placeholderImage:[UIImage imageNamed:@"image_empty.png"]];

        [listView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc] initWithFrame:CGRectMake(62, 5, kScreenWidth - 62 - 70, 35)];
        name.text = [product objectForKey:@"name"];
        name.numberOfLines = 2;
        name.font = [UIFont systemFontOfSize:12];
        [name setTextColor:[UIColor darkGrayColor]];
        [listView addSubview:name];
        
        UILabel *count = [[UILabel alloc] initWithFrame:CGRectMake(62, 35, 50, 18)];
        count.text = [NSString stringWithFormat:@"x%d", [[product objectForKey:@"num"] intValue]];
        count.font = [UIFont systemFontOfSize:12];
        [count setTextColor:[UIColor blackColor]];
        [listView addSubview:count];
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 18, 160, 18)];
        price.textAlignment = UIControlContentHorizontalAlignmentRight;
        price.text = [NSString stringWithFormat:@"￥%.2f",[[product objectForKey:@"price"] doubleValue]];
        price.font = [UIFont systemFontOfSize:12];
        [price setTextColor:[UIColor redColor]];
        [listView addSubview:price];
        
//        UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 20, 9, 15)];
//        arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
//        [listView addSubview:arrowImage];
        
        if(i != products.count - 1){
            [super setBorderWithView:listView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
        };
        [productView addSubview:listView];
    }
    [super setBorderWithView:productView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [self.scrollView addSubview:productView];
    
    //加载完成商品信息后开始载入支付配送信息
    [self loadPaymentDelivery];
}

/*
 * 载入支付配送信息
 */
- (void) loadPaymentDelivery{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/order!paymentShipping.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self initPaymentView];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [self initPaymentView];
                               return;
                           }
                           
                           NSDictionary *data = [result objectForKey:@"data"];
                           if(data == nil){
                               [self initPaymentView];
                               return;
                           }
                           shippingArray = [data objectForKey:@"shipping"];
                           paymentArray = [data objectForKey:@"payment"];
                           if(shippingArray != nil && shippingArray.count > 0){
                               shipping = [shippingArray objectAtIndex:0];
                               shippingPrice = [[shipping objectForKey:@"price"] doubleValue];
                               [self updateAmount];
                           }
                           if(paymentArray != nil && paymentArray.count > 0){
                               payment = [paymentArray objectAtIndex:0];
                           }
                           [self initPaymentView];
                       });
                   });
    
}

/**
 *  创建支付配送视图
 */
- (void) initPaymentView{
    paymnetView = [[UIView alloc] initWithFrame:CGRectMake(0, 91 + products.count * 55 + 5, kScreenWidth, 56)];
    paymnetView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"支付配送";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [paymnetView addSubview:titleLabel];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 5, 80, 15)];
    payLabel.text = [payment objectForKey:@"name"];
    payLabel.font = [UIFont systemFontOfSize:12];
    payLabel.textAlignment = NSTextAlignmentRight;
    [payLabel setTextColor:[UIColor darkGrayColor]];
    [paymnetView addSubview:payLabel];
    
    UILabel *shipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 20, 80, 15)];
    shipLabel.text = [shipping objectForKey:@"name"];
    shipLabel.font = [UIFont systemFontOfSize:12];
    shipLabel.textAlignment = NSTextAlignmentRight;
    [shipLabel setTextColor:[UIColor darkGrayColor]];
    [paymnetView addSubview:shipLabel];
    
    UILabel *shipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 35, 160, 15)];
    shipPriceLabel.text = [NSString stringWithFormat:@"物流配送费：￥%.2f", [[shipping objectForKey:@"price"] doubleValue]];
    shipPriceLabel.font = [UIFont systemFontOfSize:12];
    shipPriceLabel.textAlignment = NSTextAlignmentRight;
    [shipPriceLabel setTextColor:[UIColor redColor]];
    [paymnetView addSubview:shipPriceLabel];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 20, 9, 15)];
    arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
    //[paymnetView addSubview:arrowImage];
    
    UITapGestureRecognizer *specTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectPayment:)];
    [specTapGesture setNumberOfTapsRequired:1];
    //[paymnetView addGestureRecognizer:specTapGesture];

    
    [super setBorderWithView:paymnetView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [self.scrollView addSubview:paymnetView];
    
    //[self initReceiptView];
    [self initCouponView];
    
    [SVProgressHUD dismiss];
}

/**
 *  创建发票视图
 */
- (void) initReceiptView{
    receiptView = [[UIView alloc] initWithFrame:CGRectMake(0, 91 + products.count * 55 + 56 + 5, kScreenWidth, 56)];
    receiptView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"发票信息";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [receiptView addSubview:titleLabel];
    
    UILabel *payLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 5, 80, 15)];
    payLabel.text = receipt == nil ? @"" : [receipt objectForKey:@"type"];
    payLabel.font = [UIFont systemFontOfSize:12];
    payLabel.textAlignment = NSTextAlignmentRight;
    [payLabel setTextColor:[UIColor darkGrayColor]];
    [receiptView addSubview:payLabel];
    
    UILabel *shipLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 20, 180, 15)];
    shipLabel.text = (receipt == nil || [[receipt objectForKey:@"type"] length] == 0) ? @"不开发票" : [receipt objectForKey:@"title"];
    shipLabel.font = [UIFont systemFontOfSize:12];
    shipLabel.textAlignment = NSTextAlignmentRight;
    [shipLabel setTextColor:[UIColor darkGrayColor]];
    [receiptView addSubview:shipLabel];
    
    UILabel *shipPriceLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 120, 35, 80, 15)];
    shipPriceLabel.text = receipt == nil ? @"" : [receipt objectForKey:@"content"];
    shipPriceLabel.font = [UIFont systemFontOfSize:12];
    shipPriceLabel.textAlignment = NSTextAlignmentRight;
    [shipPriceLabel setTextColor:[UIColor darkGrayColor]];
    [receiptView addSubview:shipPriceLabel];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 20, 9, 15)];
    arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
    [receiptView addSubview:arrowImage];
    
    UITapGestureRecognizer *specTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectReceipt:)];
    [specTapGesture setNumberOfTapsRequired:1];
    //[receiptView addGestureRecognizer:specTapGesture];

    
    [super setBorderWithView:receiptView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [self.scrollView addSubview:receiptView];
}
#pragma mark CouponView
/*
    创建优惠劵视图
 */
- (void) initCouponView{
    
    couponView = [[UIView alloc] initWithFrame:CGRectMake(0, 91 + products.count * 55 + 56 + 5, kScreenWidth, 56)];
    couponView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 18, 100, 20)];
    titleLabel.text = @"优惠劵";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [couponView addSubview:titleLabel];
    
    UILabel *couponLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 200, 18, 160, 20)];
    if (_isfrist) {
        couponLabel.text = @"未选择优惠劵";
        [couponLabel setTextColor:[UIColor darkGrayColor]];
    }
    else{
        NSString *couponname = [_selectCouponDic objectForKey:@"name"];
        NSString *conponprice = [_selectCouponDic objectForKey:@"type_money"];
        couponLabel.text = [NSString stringWithFormat:@"%@：－¥%@元",couponname,conponprice];
        [couponLabel setTextColor:[UIColor redColor]];
        
    }
    
    couponLabel.font = [UIFont systemFontOfSize:12];
    couponLabel.textAlignment = NSTextAlignmentRight;
    [couponView addSubview:couponLabel];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(kScreenWidth - 20, 20, 9, 15)];
    arrowImage.image = [UIImage imageNamed:@"jshop_list_back.png"];
    [couponView addSubview:arrowImage];
    
    UITapGestureRecognizer *couponTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCoupon:)];
    [couponTapGesture setNumberOfTapsRequired:1];
    [couponView addGestureRecognizer:couponTapGesture];
    
     [super setBorderWithView:couponView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    
    [self.scrollView addSubview:couponView];
    
    [self initRemarkView];
}
- (void)selectCoupon:(UITapGestureRecognizer *)tap{
    CouponViewController *vc = (CouponViewController *)[super controllerFromMainStroryBoard:@"Coupon"];
    vc.ispaying = YES;
    vc.amount = [NSString stringWithFormat:@"%f",amount];
    [self presentViewController:vc animated:YES completion:nil];
}
- (void)selectCouponCompletion:(NSNotification*)notification{
    if (notification.userInfo != nil) {
        _selectCouponDic = [[NSMutableDictionary alloc]initWithDictionary:notification.userInfo copyItems:YES];
        _isfrist = NO;
        [couponView removeFromSuperview];
        [self initCouponView];
        //刷新优惠后的价钱
        _couponPrice = [_selectCouponDic objectForKey:@"type_money"];
        double couponPrice = [_couponPrice doubleValue];
        amountLabel.text = [NSString stringWithFormat:@"实付款:￥%.1f", amount+shippingPrice-couponPrice];
    }
    else{
        _isfrist = YES;
         [couponView removeFromSuperview];
        [self initCouponView];
        amountLabel.text = [NSString stringWithFormat:@"实付款:￥%.1f", amount+shippingPrice];
    }

    return;
}

/**
 *  创建订单备注视图
 */
- (void) initRemarkView{
    remarkView = [[UIView alloc] initWithFrame:CGRectMake(0, 91 + products.count * 55 + 56 * 2 + 10, kScreenWidth, 68)];
    remarkView.backgroundColor = [UIColor whiteColor];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, 100, 20)];
    titleLabel.text = @"订单备注";
    titleLabel.font = [UIFont systemFontOfSize:14];
    [titleLabel setTextColor:[UIColor darkGrayColor]];
    [remarkView addSubview:titleLabel];
    
    remarkTextField = [[UITextField alloc] initWithFrame:CGRectMake(8, 30, kScreenWidth - 16, 30)];
    remarkTextField.font = [UIFont systemFontOfSize:12];
    remarkTextField.textAlignment = NSTextAlignmentLeft;
    [remarkTextField setTextColor:[UIColor darkGrayColor]];
    remarkTextField.layer.borderColor = [UIColor colorWithHexString:@"#edeef0"].CGColor;
    remarkTextField.layer.borderWidth = 1.0;
    remarkTextField.layer.masksToBounds = YES;
    remarkTextField.layer.cornerRadius = 3.0;
    remarkTextField.delegate = self;
    [remarkView addSubview:remarkTextField];
    
    //注册键盘响应事件方法
    [remarkTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];

    
    [super setBorderWithView:remarkView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#edeef0"] borderWidth:0.5f];
    [self.scrollView addSubview:remarkView];
}

//键盘出现时候调用的事件
-(void) keyboadWillShow:(NSNotification *)note{
    NSDictionary *info = [note userInfo];
    double textFieldY = remarkView.frame.origin.y + 64 + 20;
    double keyboardY = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].origin.y;
    if(textFieldY + 30 > keyboardY){
        scrollView.contentOffset = CGPointMake(0, keyboardY-textFieldY + 10);
    }    
}
//键盘消失时候调用的事件
-(void)keyboardWillHide:(NSNotification *)note{
    scrollView.contentOffset = CGPointMake(0, 0);
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    [self hideKeyboard];
}

//隐藏键盘的方法
-(void)hideKeyboard{
    [remarkTextField resignFirstResponder];
}

/**
 *  新建地址
 */
- (void) createAddress{
    [self presentViewController:[super controllerFromMainStroryBoard:@"AddressEdit"] animated:YES completion:nil];
}

/**
 *  选择收货地址
 *
 *  @param gesture
 */
- (void)selectAddress:(UITapGestureRecognizer *)gesture{
    [self presentViewController:[super controllerFromMainStroryBoard:@"Address"] animated:YES completion:nil];
}

-(void)selectAddressCompletion:(NSNotification*)notification {
    NSDictionary *selectedAddress = [notification userInfo];
    address = [NSMutableDictionary dictionaryWithDictionary:selectedAddress];
    [addressView removeFromSuperview];
    [self initAddressView];
}

/**
 *  选择收货地址
 *
 *  @param gesture
 */
- (void)selectPayment:(UITapGestureRecognizer *)gesture{
    PaymentDeliveryViewController *paymentDeliveryViewController = (PaymentDeliveryViewController*)[super controllerFromMainStroryBoard:@"PaymentDelivery"];
    paymentDeliveryViewController.paymentArray = paymentArray;
    paymentDeliveryViewController.shippingArray = shippingArray;
    paymentDeliveryViewController.shipping = shipping;
    paymentDeliveryViewController.payment = payment;
    [self presentViewController:paymentDeliveryViewController animated:YES completion:nil];
}

-(void)selectPaymentDeliveryCompletion:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    payment = [userInfo objectForKey:@"payment"];
    shipping = [userInfo objectForKey:@"shipping"];
    [paymnetView removeFromSuperview];
    [self initPaymentView];
    
    shippingPrice = [[shipping objectForKey:@"price"] doubleValue];
    [self updateAmount];
}

-(void)addAddressCompletion:(NSNotification*)notification {
    address = (NSMutableDictionary*)notification.userInfo;
    [self initAddressView];
}

/**
 *  选择发票信息
 *  @param gesture
 */
- (void)selectReceipt:(UITapGestureRecognizer *)gesture{
    ReceiptViewController *receiptViewController = (ReceiptViewController*)[super controllerFromMainStroryBoard:@"Receipt"];
    if(receipt != nil){
        receiptViewController.receiptType = [receipt objectForKey:@"type"];
        receiptViewController.receiptTitle = [receipt objectForKey:@"title"];
        receiptViewController.receiptContent = [receipt objectForKey:@"content"];
    }
    [self presentViewController:receiptViewController animated:YES completion:nil];
}

-(void)selectReceiptCompletion:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    receipt = [NSMutableDictionary dictionaryWithDictionary:userInfo];
    [receiptView removeFromSuperview];
    [self initReceiptView];
}

/*
 * 提交订单
 */
- (void) submitOrder{
    if(address == nil){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请选择收货地址！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(shipping == nil){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请选择配送方式！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(payment == nil){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请选择支付方式！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在提交订单..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
                       [params setValue:[shipping objectForKey:@"type_id"] forKey:@"typeId"];
                       [params setValue:[payment objectForKey:@"id"] forKey:@"paymentId"];
                       [params setValue:[address objectForKey:@"addr_id"] forKey:@"addressId"];
                       [params setValue:remarkTextField.text forKey:@"remark"];
                       
                       //如果有用优惠劵的话
                       if (_selectCouponDic.count != 0 || !_isfrist) {
                           [params setValue:[_selectCouponDic objectForKey:@"coupon_id"] forKey:@"couponid"];
                       }
                       
                       if (_isfrist) {
                           NSLog(@"YES");
                           NSLog(@"%@",params);
                       }
                       else{
                           NSLog(@"NO");
                            NSLog(@"%@",params);
                       }
                       
                       
                       
                       NSString *content = [client post:[BASE_URL stringByAppendingString:@"/api/mobile/order!create.do"] withData:params];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"提交订单失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"提交订单失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           //保存成功
                           NSDictionary *order = [result objectForKey:@"order"];
                           [[NSNotificationCenter defaultCenter] postNotificationName:nSubmitOrder object:nil userInfo:order];

                           if([[payment objectForKey:@"type"] isEqualToString:@"cod"]) {
                               CheckoutSuccessViewController *checkoutSuccessViewController = (CheckoutSuccessViewController *) [super controllerFromMainStroryBoard:@"CheckoutSuccess"];
                               checkoutSuccessViewController.order = order;
                               checkoutSuccessViewController.payment = payment;
                               [self presentViewController:checkoutSuccessViewController animated:YES completion:nil];
                           }else if([[payment objectForKey:@"type"] isEqualToString:@"alipayMobilePlugin"] ||
                                    [[payment objectForKey:@"type"] isEqualToString:@"wechatMobilePlugin"] ||
                                    [[payment objectForKey:@"type"] isEqualToString:@"unionpayMobilePlugin"]){
                               PaymentViewController *paymentViewController = (PaymentViewController *) [super controllerFromMainStroryBoard:@"Payment"];
                               paymentViewController.order = order;
                               paymentViewController.paymentid = [[payment objectForKey:@"id"] intValue];
                               [self presentViewController:paymentViewController animated:YES completion:nil];
                           }
                           
                       });
                   });
    
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
