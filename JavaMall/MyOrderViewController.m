//
//  MyOrderViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "MyOrderViewController.h"
#include "MyOrderCell.h"
#import "UIColor+HexString.h"
#import "HttpClient.h"
#import "MJRefresh.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "OrderDetailViewController.h"

@interface MyOrderViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *headerView;
- (IBAction)back:(id)sender;

@end

@implementation MyOrderViewController{
    int page;
    NSMutableArray *orderArray;
    HttpClient *client;
    UILabel *nodataLabel;
}

@synthesize tableView, headerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    client = [[HttpClient alloc] init];
    page = 1;
    orderArray = [NSMutableArray arrayWithCapacity:0];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    //表格设置
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.backgroundColor = [UIColor colorWithHexString:@"#f3f5f7"];
    
    [self loadOrderList];
}

- (void) loadOrderList{
    if(page == 1){
        [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    }
    if(nodataLabel != nil){
        nodataLabel.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/order!list.do?page=%d", page]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               [self showNoData];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSArray *dataArray = [resultJSON objectForKey:@"data"];
                           
                           if(page == 1 && (dataArray == nil || dataArray.count == 0)){
                               [SVProgressHUD dismiss];
                               [self showNoData];
                               return;
                           }
                           [orderArray addObjectsFromArray:dataArray];
                           [tableView reloadData];
                           if(page == 1){
                               [SVProgressHUD dismiss];
                           }
                           
                           __weak __typeof(self) weakSelf = self;
                           if(self.tableView.footer == nil){
                               self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                   page++;
                                   [weakSelf loadOrderList];
                               }];
                           }else{
                               [self.tableView.footer endRefreshing];
                           }
                           
                       });
                   });
}

/**
 *  没有数据时显示
 */
- (void) showNoData{
    if(nodataLabel == nil){
        nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight)];
        [nodataLabel setText: @"抱歉，您暂时还没有订单"];
        nodataLabel.textAlignment = NSTextAlignmentCenter;
        [nodataLabel setFont:[UIFont fontWithName:kFont size:14]];
        [nodataLabel setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:nodataLabel];
    }
    nodataLabel.hidden = NO;
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
    return [orderArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *order = [orderArray objectAtIndex:indexPath.row];
    NSArray *itemArray = [order objectForKey:@"itemList"];
    if(itemArray == nil || itemArray.count == 0){
        return 85;
    }
    return 85 + 55 * itemArray.count;
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
    static NSString *cellIdentifier = @"MyOrderCell";
    MyOrderCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *order = [orderArray objectAtIndex:indexPath.row];
    NSArray *itemArray = [order objectForKey:@"itemList"];
    NSUInteger itemCount = 0;
    if(itemArray != nil){
        itemCount = itemArray.count;
    }
    
    for (UIView *view in cell.conView.subviews) {
        [view removeFromSuperview];
    }
    
    for(int i = 0; i < itemCount; i++){
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
        
        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 70, 18, 80, 18)];
        price.text = [NSString stringWithFormat:@"￥%.2f", [[item objectForKey:@"price"] doubleValue]];
        price.font = [UIFont systemFontOfSize:12];
        [price setTextColor:[UIColor redColor]];
        [listView addSubview:price];
        
        [cell.conView addSubview:listView];
    }

    cell.orderNumber.text = [NSString stringWithFormat:@"订单号：%@", [order objectForKey:@"sn"]];
    cell.orderStatus.text = [order objectForKey:@"orderStatus"];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 55 * itemCount, kScreenWidth, 40)];
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 200, 20)];
    amountLabel.text = [NSString stringWithFormat:@"实付款：￥%.2f", [[order objectForKey:@"order_amount"] doubleValue]];
    amountLabel.font = [UIFont systemFontOfSize:14];
    amountLabel.textColor = [UIColor darkGrayColor];
    [footerView addSubview:amountLabel];
    [super setBorderWithView:footerView top:YES left:NO bottom:NO right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [cell.conView addSubview:footerView];
    return cell;
}

/**
 *  选中行
 *
 *  @param tableView
 *  @param indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *order = [orderArray objectAtIndex:[indexPath row]];
    OrderDetailViewController *orderDetailViewController = (OrderDetailViewController *)[super controllerFromMainStroryBoard:@"OrderDetail"];
    orderDetailViewController.orderid = [[order objectForKey:@"order_id"] intValue];
    [self presentViewController:orderDetailViewController animated:YES completion:nil];
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)c forRowAtIndexPath:(NSIndexPath *)indexPath {
    MyOrderCell *cell = (MyOrderCell *)c;
    
    cell.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.frame.size.height - 5, kScreenWidth, 5)];
    cell.lineView.backgroundColor = [UIColor colorWithHexString:@"#f3f5f7"];
    [super setBorderWithView:cell.lineView top:YES left:NO bottom:NO right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [cell addSubview:cell.lineView];
    [super setBorderWithView:cell.headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:cell.contentView top:YES left:NO bottom:NO right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
