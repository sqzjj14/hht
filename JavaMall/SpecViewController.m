//
//  SpecViewController.m
//  JavaMall
//
//  Created by Dawei on 6/28/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "SpecViewController.h"
#import "UIColor+HexString.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "SpecButton.h"
#import "MSViewControllerSlidingPanel.h"
#import "GoodsViewController.h"
#import "UIImageView+WebCache.h"

@interface SpecViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *sn;

@property (weak, nonatomic) GoodsViewController *goodsViewController;

@end

@implementation SpecViewController{
    HttpClient *client;
    NSMutableDictionary *productDic;
    
    NSSortDescriptor *sortDescriptor;
    NSMutableDictionary *selectedSpecId;
    
    UITextView *countText;
    
    UIScrollView *specView;
}

@synthesize goodsViewController;
@synthesize btn, mainView, image, price, sn;
@synthesize product;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //初始化规格选择视图
    specView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 103, mainView.frame.size.width, mainView.frame.size.height - 103 - 45)];
    [mainView addSubview:specView];
    
    client = [[HttpClient alloc] init];
    productDic = [[NSMutableDictionary alloc] init];
    selectedSpecId = [[NSMutableDictionary alloc] init];
    sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    
    [self loadData];
    
    //载入底部
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 45, kScreenWidth, 45)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:0.9f];
    
    UIView *addToCartView = [[UIView alloc] initWithFrame:CGRectMake(135, 0, 150, 45)];
    addToCartView.backgroundColor = [UIColor colorWithHexString:@"#f15352"];
    UIButton *addToCartBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 150, 45)];
    [addToCartBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [addToCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addToCartBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [addToCartBtn addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    [addToCartView addSubview:addToCartBtn];
    
    [bottomView addSubview:addToCartView];
    [self.view addSubview:bottomView];
    
    [self loadSpec];
    
    goodsViewController = (GoodsViewController *)[self slidingPanelController].centerViewController;
    
}

/**
 *  载入数据
 */
- (void) loadData{
    if([product objectForKey:@"thumbnail"] != nil && [[product objectForKey:@"thumbnail"] isKindOfClass:[NSString class]]){
        [image sd_setImageWithURL:[NSURL URLWithString:[product objectForKey:@"thumbnail"]]
                 placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
    }else{
        image.image = [UIImage imageNamed:@"image_empty.png"];
    }
    [price setText:[NSString stringWithFormat:@"￥%@", [product objectForKey:@"price"]]];
    [sn setText:[NSString stringWithFormat:@"商品编号：%@", [product objectForKey:@"sn"]]];
    
}

/**
 *  载入商品详细信息
 */
- (void) loadSpec{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!spec.do?id=%@", [product objectForKey:@"goods_id"]]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *dataJSON = [resultJSON objectForKey:@"data"];
                           if((int)[dataJSON objectForKey:@"have_spec"] == 0){
                               [SVProgressHUD dismiss];
                               return;
                           }
                           
                           //保存产品
                           NSArray *products = [dataJSON objectForKey:@"productList"];
                           for (NSDictionary *_product in products) {
                               NSMutableArray *keyValueList = [NSMutableArray arrayWithCapacity:0];
                               NSArray *specList = [_product objectForKey:@"specList"];
                               for (NSDictionary *specValue in specList) {
                                   int v = [[specValue objectForKey:@"spec_value_id"] intValue];
                                   [keyValueList addObject:[NSNumber numberWithInt:v]];
                               }
                               
                               //排序
                               [keyValueList sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                               [productDic setValue:_product forKey:[keyValueList componentsJoinedByString:@"-"]];
                           }
                           
                           int startY = 10;
                           NSArray *specArray = [dataJSON objectForKey:@"specList"];
                           NSDictionary *attributeButton = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
                           for (NSDictionary *spec in specArray) {
                               int spec_id = (int)[spec objectForKey:@"spec_id"];
                               
                               UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, startY, 100, 25)];
                               [label setText:[spec objectForKey:@"spec_name"]];
                               [label setFont:[UIFont systemFontOfSize:14]];
                               [label setTextColor:[UIColor colorWithHexString:@"#7e7e7e"]];
                               [specView addSubview:label];
                               
                               NSArray *specValueArray = [spec objectForKey:@"valueList"];
                               int i = 0;
                               for (NSDictionary *specValue in specValueArray) {
                                   NSString *buttonTitle = [specValue objectForKey:@"spec_value"];
                                   CGSize buttonSize = [buttonTitle boundingRectWithSize:CGSizeMake(MAXFLOAT,40) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeButton context:nil].size;
                                   
                                   SpecButton *button = [[SpecButton alloc] initWithFrame:CGRectMake(80, startY, buttonSize.width + 30, 25)];
                                   [button setTitle:buttonTitle forState:UIControlStateNormal];
                                   [button setTitleColor:[UIColor colorWithHexString:@"#7d7d7d"] forState:UIControlStateNormal];
                                   [button.titleLabel setFont:[UIFont systemFontOfSize:12]];
                                   button.layer.borderColor = [[UIColor colorWithHexString:@"#ebebeb"] CGColor];
                                   button.layer.borderWidth = 1.0f;
                                   button.layer.masksToBounds = YES;
                                   button.layer.cornerRadius = 3.0;
                                   [button addTarget:self action:@selector(selectSpec:) forControlEvents:UIControlEventTouchUpInside];
                                   button.spec_id = spec_id;
                                   button.specvalue_id = [[specValue objectForKey:@"spec_value_id"] intValue];
                                   
                                   [specView addSubview:button];
                                   if(i == 0){
                                       button.layer.borderColor = [[UIColor redColor] CGColor];
                                       [selectedSpecId setObject:[NSNumber numberWithInt:button.specvalue_id] forKey:[NSNumber numberWithInt:spec_id]];
                                   }
                                   i++;
                                   startY += 30;
                               }
                               startY += 10;
                           }
                           
                           //数量
                           UILabel *countLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, startY, 100, 25)];
                           [countLabel setText:@"数量"];
                           [countLabel setFont:[UIFont systemFontOfSize:14]];
                           [countLabel setTextColor:[UIColor colorWithHexString:@"#7e7e7e"]];
                           [specView addSubview:countLabel];
                           
                           //减
                           UIButton *lessButton = [[UIButton alloc] initWithFrame:CGRectMake(80, startY, 25, 25)];
                           [lessButton setImage:[UIImage imageNamed:@"syncart_less_btn_enable.png"] forState:UIControlStateNormal];
                           [lessButton addTarget:self action:@selector(less) forControlEvents:UIControlEventTouchUpInside];
                           [specView addSubview:lessButton];
                           
                           //输入框
                           countText = [[UITextView alloc] initWithFrame:CGRectMake(105, startY, 40, 25)];
                           countText.layer.borderWidth = 0;
                           [countText setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"syncart_middle_btn_enable.png"]]];
                           [countText setTextAlignment:NSTextAlignmentCenter];
                           [countText setFont:[UIFont systemFontOfSize:12]];
                           [countText setFrame:CGRectMake(countText.frame.origin.x, countText.frame.origin.y, 40, 25)];
                           countText.text = @"1";
                           [specView addSubview:countText];
                           
                           //加
                           UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(145, startY, 25, 25)];
                           [addButton setImage:[UIImage imageNamed:@"syncart_more_btn_enable.png"] forState:UIControlStateNormal];
                           [addButton addTarget:self action:@selector(add) forControlEvents:UIControlEventTouchUpInside];
                           [specView addSubview:addButton];
                           
                           specView.contentSize = CGSizeMake(mainView.frame.size.width, startY + 35);
                           
                           [SVProgressHUD dismiss];
                           
                       });
                   });
}

/**
 *  添加到购物车
 */
- (void) addToCart{
    [goodsViewController addToCart:[countText.text intValue]];
}

- (void) less{
    int count = [countText.text intValue];
    if(count > 1){
        countText.text = [NSString stringWithFormat:@"%d", (count-1)];
    }
}

- (void) add{
    int count = [countText.text intValue];
    countText.text = [NSString stringWithFormat:@"%d", (count+1)];
}

/**
 *  选择规格
 *
 *  @param sender
 */
- (void) selectSpec:(SpecButton *)sender{
    //取消所有
    NSArray *subViews = [specView subviews];
    for (UIView *view in subViews) {
        if([view isKindOfClass:[SpecButton class]]){
            SpecButton *_btn = (SpecButton *)view;
            if(_btn.spec_id == sender.spec_id){
                view.layer.borderColor = [[UIColor colorWithHexString:@"#ebebeb"] CGColor];
            }
        }
    }
    sender.layer.borderColor = [[UIColor redColor] CGColor];
    [selectedSpecId setObject:[NSNumber numberWithInt:sender.specvalue_id] forKey:[NSNumber numberWithInt:sender.spec_id]];
    [self changeSpec];
}

/**
 *  改变规格
 */
- (void) changeSpec{
    NSMutableArray *keyArray = [[NSMutableArray alloc] init];
    NSArray *array = [selectedSpecId allValues];
    [keyArray addObjectsFromArray:array];
    [keyArray sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSDictionary *_product = [productDic objectForKey:[keyArray componentsJoinedByString:@"-"]];
    
    [price setText:[NSString stringWithFormat:@"￥%d", [[_product objectForKey:@"price"] intValue]]];
    [sn setText:[NSString stringWithFormat:@"商品编号：%@", [_product objectForKey:@"sn"]]];
    
    [goodsViewController setProduct:_product count:[countText.text intValue]];
    
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    [super setBorderWithView:mainView top:NO left:YES bottom:NO right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
