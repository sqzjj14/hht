//
//  MyFavoriteViewController.m
//  JavaMall
//
//  Created by Dawei on 7/9/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "MyFavoriteViewController.h"
#import "UIColor+HexString.h"
#import "MyFavoriteCell.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "GoodsNavigationViewController.h"

@interface MyFavoriteViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
- (IBAction)back:(id)sender;

@end

@implementation MyFavoriteViewController{
    HttpClient *client;
    int page;
    NSMutableArray *favoriteArray;
    
    UILabel *nodataLabel;
}

@synthesize headerView, tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    client = [[HttpClient alloc] init];
    page = 1;
    favoriteArray = [NSMutableArray arrayWithCapacity:0];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self loadFavorites];
}

- (void) loadFavorites{
    if(page == 1){
        [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    }
    if(nodataLabel != nil){
        nodataLabel.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/favorite!list.do?page=%d", page]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               [self showNoData];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[resultJSON objectForKey:@"result"] intValue] != 1){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"未登录或登录已过期，请重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                               [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                               return;
                           }
                           NSArray *dataArray = [resultJSON objectForKey:@"data"];
                           if(page == 1 && (dataArray == nil || dataArray.count == 0)){
                               [SVProgressHUD dismiss];
                               [self showNoData];
                               return;
                           }
                           
                           [favoriteArray addObjectsFromArray:dataArray];
                           [tableView reloadData];
                           if(page == 1){
                               [SVProgressHUD dismiss];
                           }
                           
                           __weak __typeof(self) weakSelf = self;
                           if(self.tableView.footer == nil){
                               self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                   page++;
                                   [weakSelf loadFavorites];
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
        [nodataLabel setText: @"抱歉，您没有收藏任何商品"];
        nodataLabel.textAlignment = NSTextAlignmentCenter;
        [nodataLabel setFont:[UIFont fontWithName:kFont size:14]];
        [nodataLabel setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:nodataLabel];
    }
    nodataLabel.hidden = NO;
}

/**
 *  设置tableview的数据总数
 *
 *  @param tableView
 *  @param section
 *
 *  @return
 */
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return favoriteArray.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSDictionary *favorite = [favoriteArray objectAtIndex:indexPath.row];
        
        [SVProgressHUD showWithStatus:@"正在删除收藏..." maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/favorite!delete.do?favoriteid=%@", [favorite objectForKey:@"favorite_id"]]];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               
                               if([content length] == 0){
                                   [SVProgressHUD setErrorImage:nil];
                                   [SVProgressHUD showErrorWithStatus:@"删除收藏失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                                   return;
                               }
                               
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([[result objectForKey:@"result"] intValue] == 0){
                                   [SVProgressHUD setErrorImage:nil];
                                   [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                                   return;
                               }
                               
                               //删除成功,保存数据
                               [favoriteArray removeObjectAtIndex:indexPath.row];
                               [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                           });
                       });
    }
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
    static NSString *cellIdentifier = @"MyFavorite";
    MyFavoriteCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *goods = [favoriteArray objectAtIndex:[indexPath row]];
    
    cell.name.text = [goods objectForKey:@"name"];
    cell.price.text = [NSString stringWithFormat:@"￥%@", [goods objectForKey:@"price"]];
    cell.comments.text = [NSString stringWithFormat:@"%d人已购买", (int)[goods objectForKey:@"buy_count"]];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:[goods objectForKey:@"thumbnail"]]
                  placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
    
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
    NSDictionary *goods = [favoriteArray objectAtIndex:[indexPath row]];
    GoodsNavigationViewController *goodsNavigationController = (GoodsNavigationViewController *)[super controllerFromMainStroryBoard:@"GoodsNavigation"];
    goodsNavigationController.goods_id = [[goods objectForKey:@"goods_id"] intValue];
    [self presentViewController:goodsNavigationController animated:YES completion:nil];

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
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
