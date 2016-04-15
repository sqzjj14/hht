//
//  CartViewController.m
//  JavaMall
//
//  Created by Dawei on 6/25/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "CartViewController.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "UIColor+HexString.h"
#import "CartCell.h"
#import "HttpClient.h"
#import "UIImageView+WebCache.h"
#import "Constants.h"

@interface CartViewController()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *operationViewVertical;
@property (nonatomic,assign) NSInteger amout;

@end

@implementation CartViewController{
    UIView *nodataView;
    UIView *checkoutView;
    UIView *operateView;
    UILabel *amountLabel;
    
    HttpClient *client;
    NSMutableArray *cartItems;
    
    BOOL cartEditing;
}

@synthesize headerView, bottomView, tableView;
@synthesize editBtn, backBtn;

- (void) viewDidLoad{
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    if(self.tabBarController == nil){
        self.operationViewVertical.constant = 0;
    }else{
        self.operationViewVertical.constant = 49;
    }
    
    client = [[HttpClient alloc] init];
    cartItems = [NSMutableArray arrayWithCapacity:0];
    cartEditing = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    if([self navigationController] == nil){
        backBtn.hidden = YES;
    }else{
        backBtn.hidden = NO;
    }
    
    [self showCheckoutView];
}

- (void)viewDidAppear:(BOOL)animated{
    if([[Constants action] isEqualToString:@"index"]){
        [Constants setAction:nil];
        if([self navigationController] == nil){
            [self tabBarController].selectedIndex = 0;
        }else{
            [self.navigationController popToRootViewControllerAnimated:NO];
        }
    }else{
        [self reloadCart];
        NSLog(@"重新载入购物车商品列表");
    }
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

/**
 *  创建结算视图
 */
- (void) showCheckoutView{
    [bottomView setBackgroundColor:[UIColor colorWithHexString:@"#303030"]];
    [bottomView setAlpha:0.8f];
    operateView.hidden = YES;
    if(checkoutView == nil){
        checkoutView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        
        amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 150, 25)];
        [amountLabel setTextColor:[UIColor whiteColor]];
        [amountLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [checkoutView addSubview:amountLabel];
        
        UIButton *checkoutButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 100, 0, 100, 44)];
        [checkoutButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
        [checkoutButton setTitle:@"去结算" forState:UIControlStateNormal];
        [checkoutButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
        [checkoutButton addTarget:self action:@selector(checkout) forControlEvents:UIControlEventTouchUpInside];
        [checkoutView addSubview:checkoutButton];
        [bottomView addSubview:checkoutView];
    }else{
        checkoutView.hidden = NO;
    }
}

/**
 *  创建操作视图
 */
- (void) showOperateView{
    [bottomView setBackgroundColor:[UIColor colorWithHexString:@"#eaedf2"]];
    [bottomView setAlpha:0.8f];
    checkoutView.hidden = YES;
    if(operateView == nil){
        operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 44)];
        
        UIButton *selectAllBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 13, 58, 18)];
        [selectAllBtn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
        [selectAllBtn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateSelected];
        [selectAllBtn setTitle:@"全选" forState:UIControlStateNormal];
        [selectAllBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        selectAllBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [selectAllBtn addTarget:self action:@selector(selectAllCell:) forControlEvents:UIControlEventTouchUpInside];
        
        [operateView addSubview:selectAllBtn];
        
        UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 80, 9, 60, 25)];
        [deleteButton setBackgroundColor:[UIColor whiteColor]];
        [deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        deleteButton.layer.borderColor = [UIColor colorWithHexString:@"#be161a"].CGColor;
        deleteButton.layer.borderWidth = 0.5f;
        deleteButton.layer.masksToBounds = YES;
        deleteButton.layer.cornerRadius = 2.0;
        [deleteButton addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
        [operateView addSubview:deleteButton];
        
        UIButton *favoriteButton = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 150, 9, 60, 25)];
        [favoriteButton setBackgroundColor:[UIColor whiteColor]];
        [favoriteButton setTitle:@"移入收藏" forState:UIControlStateNormal];
        [favoriteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [favoriteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        favoriteButton.layer.borderColor = [UIColor colorWithHexString:@"#d0d1d5"].CGColor;
        favoriteButton.layer.borderWidth = 0.5f;
        favoriteButton.layer.masksToBounds = YES;
        favoriteButton.layer.cornerRadius = 2.0;
        [favoriteButton addTarget:self action:@selector(favorite:) forControlEvents:UIControlEventTouchUpInside];
        [operateView addSubview:favoriteButton];
        [self setBorderWithView:operateView top:YES left:NO bottom:NO right:NO borderColor:[UIColor colorWithHexString:@"#e0e3e8"] borderWidth:0.5f];
        
        [bottomView addSubview:operateView];
    }else{
        operateView.hidden = NO;
    }
}

/**
 *  显示没有商品界面
 */
- (void) nodata:(BOOL) show{
    if(show){
        //隐藏操作栏
        bottomView.hidden = YES;
        
        //修改编辑模式
        cartEditing = NO;
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        editBtn.hidden = YES;
        
        if(nodataView == nil){
            nodataView = [[UIView alloc] initWithFrame:CGRectMake(0, 95, kScreenWidth, kScreenHeight)];
            //图片
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-110) / 2, 150, 93, 78)];
            imageView.image = [UIImage imageNamed:@"cartNoContentIcon.png"];
            [nodataView addSubview:imageView];
            
            //提示信息
            NSString *txt = @"购物车是空的";
            NSDictionary *attributeButton = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
            CGSize labelSize = [txt boundingRectWithSize:CGSizeMake(MAXFLOAT,40) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeButton context:nil].size;
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - labelSize.width) / 2, imageView.frame.origin.y + 93 + 10, labelSize.width, 25)];
            [label setText: txt];
            label.textAlignment = NSTextAlignmentCenter;
            [label setTextColor:[UIColor darkGrayColor]];
            [label setFont:[UIFont fontWithName:kFont size:14]];
            [label setBackgroundColor:[UIColor whiteColor]];
            
            [nodataView addSubview:label];
            [self.view addSubview:nodataView];
        }else{
            nodataView.hidden = NO;
        }
        
    }else{
        bottomView.hidden = NO;
        cartEditing = NO;
        editBtn.hidden = NO;
        if(nodataView != nil){
            nodataView.hidden = YES;
        }
    }
}

- (void) reloadCart{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    [cartItems removeAllObjects];
    [tableView reloadData];
    amountLabel.text = @"合计:￥0.0";
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/cart!list.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               [self nodata:YES];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *data = [result objectForKey:@"data"];
                           
                           if(data == nil){
                               [SVProgressHUD dismiss];
                               [self nodata:YES];
                               return;
                           }
                           
                           NSArray *goodsList = [data objectForKey:@"goodslist"];
                           if(goodsList == nil || goodsList.count == 0){
                               [SVProgressHUD dismiss];
                               [self nodata:YES];
                               return;
                           }
                           
                           [self nodata:NO];
                           [self showCheckoutView];
                           
                           //购物车商品
                           for (NSDictionary *item in goodsList) {
                               [cartItems addObject:[NSMutableDictionary dictionaryWithDictionary:item]];
                           }
                           //总价
                           amountLabel.text = [NSString stringWithFormat:@"合计:￥%.2f", [[data objectForKey:@"total"] doubleValue]];
                           _amout = [[data objectForKey:@"total"]intValue];
                           [tableView reloadData];
                           [SVProgressHUD dismiss];
                           
                       });
                   });
}

#pragma tableview
/**
 *  设置tableview的数据总数
 *
 *  @param tableView
 *  @param section
 *
 *  @return
 */
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return cartItems.count;
}

/**
 *  设置cell样式
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return
 */
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"CartCell";
    CartCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *item = [cartItems objectAtIndex:indexPath.row];
    
    cell.goodsName.text = [item objectForKey:@"name"];
    cell.goodsPrice.text = [NSString stringWithFormat:@"￥%.2f",[[item objectForKey:@"price"] doubleValue]];
    cell.goodsCount.text = [NSString stringWithFormat:@"%d",[[item objectForKey:@"num"] intValue]];
    
    [cell.goodsImage sd_setImageWithURL:[NSURL URLWithString:[item objectForKey:@"image_default"]]
                       placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
    [cell.selectedBtn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
    [cell.selectedBtn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateSelected];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if(cartEditing){
        cell.selectedBtn.hidden = NO;
        cell.imageLeft.constant = 5;
        if([[item objectForKey:@"selected"] isEqual:@"1"]){
            [cell.selectedBtn setSelected:YES];
        }else{
            [cell.selectedBtn setSelected:NO];
        }
    }else{
        cell.selectedBtn.hidden = YES;
        cell.imageLeft.constant = -20;
    }
    cell.productid = [[item objectForKey:@"product_id"] intValue];
    cell.cartItemId = [[item objectForKey:@"id"] intValue];
    cell.cartReloadDelegate = self;
    cell.selectedBtn.tag = indexPath.row;
    [cell.selectedBtn addTarget:self action:@selector(selectCell:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

/*
 * 选择行
 */
- (IBAction)selectCell:(id)sender {
    UIButton *selectedBtn = (UIButton *)sender;
    if(selectedBtn.isSelected){
        [selectedBtn setSelected:NO];
        [[cartItems objectAtIndex:selectedBtn.tag] setObject:@"0" forKey:@"selected"];
    }else{
        [selectedBtn setSelected:YES];
        [[cartItems objectAtIndex:selectedBtn.tag] setObject:@"1" forKey:@"selected"];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)c forRowAtIndexPath:(NSIndexPath *)indexPath {
    CartCell *cell = (CartCell *)c;
    [super setBorderWithView:cell.contentView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

/*
 * 移入收藏
 */
-(void) favorite:(id)sender{
    BOOL selectItem = NO;
    for (NSMutableDictionary *item in cartItems) {
        if([[item objectForKey:@"selected"] isEqual:@"1"]){
            selectItem = YES;
            break;
        }
    }
    if(!selectItem){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"您还没有选择商品哦！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if ([super isLogined] == NO) {
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在移入收藏..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content;
                       for (NSMutableDictionary *item in cartItems) {
                           if([[item objectForKey:@"selected"] isEqual:@"1"]){
                               content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/favorite!add.do?id=%d", [[item objectForKey:@"goods_id"] intValue]]];
                               if(content.length == 0){
                                   break;
                               }
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([[result objectForKey:@"result"] intValue] != 1){
                                   break;
                               }
                           }
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"移入收藏失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == -1){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"未登录或登录已过期，请重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                               [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                               return;
                           }
                           
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"移入收藏失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           [SVProgressHUD setInfoImage:nil];
                           [SVProgressHUD showInfoWithStatus:@"移入收藏成功！" maskType:SVProgressHUDMaskTypeBlack];
                       });
                   });
}

/*
 * 删除
 */
-(void) delete:(id)sender{
    int selectItemCount = 0;
    for (NSMutableDictionary *item in cartItems) {
        if([[item objectForKey:@"selected"] isEqual:@"1"]){
            selectItemCount++;
        }
    }
    if(selectItemCount == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"您还没有选择商品哦！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if ([super isLogined] == NO) {
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"您确认要删除这%d种商品吗？", selectItemCount]
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"确定"
                                                    otherButtonTitles:nil
                                  ];  
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=[actionSheet cancelButtonIndex]){
        [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           for (NSMutableDictionary *item in cartItems) {
                               if([[item objectForKey:@"selected"] isEqual:@"1"]){
                                   [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/cart!delete.do?cartid=%d", [[item objectForKey:@"id"] intValue]]];
                               }
                           }
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               [self reloadCart];
                               [super updateCartBadge];
                           });
                       });
    }
}

/*
 * 编辑
 */
- (IBAction)edit:(id)sender {
    if(cartEditing){
        cartEditing = NO;
        [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [self showCheckoutView];
    }else{
        cartEditing = YES;
        [editBtn setTitle:@"完成" forState:UIControlStateNormal];
        [self showOperateView];
    }
    [tableView reloadData];
}

/*
 * 后退
 */
- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 * 结算
 */
- (void) checkout{
    if ([super isLogined] == NO) {
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    if (_amout < 1000) {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"金额未满1000元无法下单！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [self presentViewController:[super controllerFromMainStroryBoard:@"Checkout"] animated:YES completion:nil];
}

/*
 * 全选
 */
- (void) selectAllCell:(id)sender{
//    UIButton *selectAllBtn = (UIButton *)sender;
//    NSArray *anArrayOfIndexPath = [NSArray arrayWithArray:[tableView indexPathsForVisibleRows]];
//    for (int i = 0; i < [anArrayOfIndexPath count]; i++) {
//        NSIndexPath *indexPath= [anArrayOfIndexPath objectAtIndex:i];
//        //取得对应的cell
//        CartCell *cell = (CartCell*)[tableView cellForRowAtIndexPath:indexPath];
//        NSUInteger row = [indexPath row];
//        NSMutableDictionary *item = [cartItems objectAtIndex:row];
//        if (selectAllBtn.isSelected) {
//            [item setObject:@"0" forKey:@"selected"];
//            [cell.selectedBtn setSelected:NO];
//        }else {
//            [item setObject:@"1" forKey:@"selected"];
//            [cell.selectedBtn setSelected:YES];
//        }
//    }
//    if(selectAllBtn.isSelected){
//        [selectAllBtn setSelected:NO];
//    }else{
//        [selectAllBtn setSelected:YES];
//    }
    
    UIButton *selectAllBtn = (UIButton *)sender;
    if(selectAllBtn.isSelected){
        [selectAllBtn setSelected:NO];
    }else{
        [selectAllBtn setSelected:YES];
    }
    for (NSMutableDictionary *item in cartItems) {
        if (selectAllBtn.isSelected) {
            [item setObject:@"1" forKey:@"selected"];
        }else {
            [item setObject:@"0" forKey:@"selected"];
        }
    }
    [tableView reloadData];
}
@end
