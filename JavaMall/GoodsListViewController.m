//
//  GoodsListViewController.m
//  JavaMall
//
//  Created by Dawei on 6/27/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "GoodsListViewController.h"
#import "UIColor+HexString.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "GoodsListCell.h"
#import "UIImageView+WebCache.h"
#import "MJRefresh.h"
#import "GoodsNavigationViewController.h"
#import "SearchViewController.h"

@interface GoodsListViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UILabel *searchKeyword;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentX;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceX;

@end


@implementation GoodsListViewController{
    NSString *sortType;
    int page;
    NSMutableArray *goodsArray;
    HttpClient *client;
    UILabel *nodataLabel;
}

@synthesize headerView, searchView, cid, brand, tableView, seckill;
@synthesize salesBtn, commentBtn, priceBtn, goodsNewBtn;
@synthesize keyword, searchKeyword;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    client = [[HttpClient alloc] init];
    
    //tap手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchEvent:)];
    [tapGesture setNumberOfTapsRequired:1];
    
    //搜索框设置
    searchView.layer.borderColor = [UIColor colorWithHexString:@"#dbdbdb"].CGColor;
    searchView.layer.borderWidth = 1.0;
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    searchView.userInteractionEnabled = YES;
    [searchView addGestureRecognizer:tapGesture];
    
    sortType = @"buynum_desc";
    page = 1;
    goodsArray = [NSMutableArray arrayWithCapacity:0];
    [self loadGoodsList];
    
    //列表设置
    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void) loadGoodsList{
    if(keyword.length > 0){
        searchKeyword.text = keyword;
        searchKeyword.textColor = [UIColor darkGrayColor];
    }else{
        searchKeyword.text = @"搜索商品";
        searchKeyword.textColor = [UIColor colorWithHexString:@"#999999"];
    }
    
    if(page == 1){
        [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    }
    if(nodataLabel != nil){
        nodataLabel.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *param = [NSString stringWithFormat:@"page=%d&sort=%@", page, sortType];
                       if(cid > 0){
                           param = [param stringByAppendingFormat:@"&cat=%d", cid];
                       }
                       if([keyword length] > 0){
                           param = [param stringByAppendingFormat:@"&keyword=%@", keyword];
                       }
                       if(brand > 0){
                           param = [param stringByAppendingFormat:@"&brand=%d", brand];
                       }
                       if(seckill > 0){
                           param = [param stringByAppendingString:@"&seckill=1"];
                       }
                       
                       NSString *url = [[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!list.do?%@", param] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                       NSLog(@"goodlist = %@",url);
                       NSString *content = [client get:url];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0 && page == 1){
                               [self showNoData];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSArray *dataArray = [resultJSON objectForKey:@"data"];
                           
                           if((dataArray == nil || dataArray.count == 0)){
                               if(page == 1){
                                   [self showNoData];
                               }else{
                                   self.tableView.footer.hidden = YES;
                               }
                               return;
                           }
                           
                           for (NSDictionary *data in dataArray) {
                               [goodsArray addObject:data];
                           }
                           [tableView reloadData];
                           if(page == 1){
                               [SVProgressHUD dismiss];
                           }
                           
                           __weak __typeof(self) weakSelf = self;
                           if(self.tableView.footer == nil){
                               self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                   page++;
                                   [weakSelf loadGoodsList];
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
        nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 98, kScreenWidth, kScreenHeight)];
        [nodataLabel setText: @"抱歉，没有符合条件的商品"];
        nodataLabel.textAlignment = NSTextAlignmentCenter;
        [nodataLabel setFont:[UIFont fontWithName:kFont size:14]];
        [nodataLabel setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:nodataLabel];
    }
    nodataLabel.hidden = NO;
}

/**
 *  点击手势
 *
 *  @param gesture
 */
- (void)searchEvent:(UITapGestureRecognizer *)gesture{
    SearchViewController *searchViewController = (SearchViewController *)[super controllerFromMainStroryBoard:@"Search"];
    searchViewController.delegate = self;
    [self presentViewController:searchViewController animated:YES completion:nil];
}

- (void)search:(NSString *)_keyword{
    sortType = @"buynum_desc";
    keyword = _keyword;
    page = 1;
    [goodsArray removeAllObjects];
    [self loadGoodsList];
}


/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    self.commentX.constant = (kScreenWidth - 165) / 3;
    self.priceX.constant = (kScreenWidth - 165) / 3;
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
    return goodsArray.count;
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
    static NSString *cellIdentifier = @"Goods";
    GoodsListCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *goods = [goodsArray objectAtIndex:[indexPath row]];
    
    cell.name.text = [goods objectForKey:@"name"];
    cell.price.text = [NSString stringWithFormat:@"￥%.2f", [[goods objectForKey:@"price"] doubleValue]];
    cell.comments.text = [NSString stringWithFormat:@"%d人已购买", [[goods objectForKey:@"buy_count"] intValue]];
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
    NSDictionary *goods = [goodsArray objectAtIndex:[indexPath row]];
    GoodsNavigationViewController *goodsNavigationController = (GoodsNavigationViewController *)[super controllerFromMainStroryBoard:@"GoodsNavigation"];
    goodsNavigationController.goods_id = [[goods objectForKey:@"goods_id"] intValue];
    [self presentViewController:goodsNavigationController animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  设置排序
 *
 *  @param sender
 */
- (IBAction)sortClick:(id)sender {
    [salesBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [commentBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [priceBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [goodsNewBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [priceBtn setImage:[UIImage imageNamed:@"sort_price_icon.png"] forState:UIControlStateNormal];
    if(sender == salesBtn){
        sortType = @"buynum_desc";
        [salesBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else if(sender == commentBtn){
        sortType = @"grade_desc";
        [commentBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }else if(sender == priceBtn){
        if ([sortType isEqualToString:@"price_asc"]) {
            sortType = @"price_desc";
        }else{
            sortType = @"price_asc";
        }
        [priceBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        if([sortType isEqualToString:@"price_asc"]){
            [priceBtn setImage:[UIImage imageNamed:@"sort_down_price_icon.png"] forState:UIControlStateNormal];
        }else{
            [priceBtn setImage:[UIImage imageNamed:@"sort_up_price_icon.png"] forState:UIControlStateNormal];
        }
    }else if(sender == goodsNewBtn){
        sortType = @"buynum_asc";
        [goodsNewBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    }
    page = 1;
    [goodsArray removeAllObjects];
    [self loadGoodsList];
}

- (IBAction)back:(id)sender {
    if(self.navigationController != nil){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
