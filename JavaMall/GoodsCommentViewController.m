//
//  GoodsCommentViewController.m
//  JavaMall
//
//  Created by Dawei on 6/30/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "GoodsCommentViewController.h"
#import "UIColor+HexString.h"
#import "GoodsCommentCell.h"
#import "MJRefresh.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "DateHelper.h"

@interface GoodsCommentViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *navView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UIButton *askButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *prototypeCell;
- (IBAction)back:(id)sender;

@end

@implementation GoodsCommentViewController{
    int type;
    int page;
    HttpClient *client;
    NSMutableArray *commentArray;
    UILabel *nodataLabel;
}

@synthesize goods_id;
@synthesize headerView, navView, tableView;
@synthesize commentButton, askButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    client = [[HttpClient alloc] init];
    type = 1;
    page = 1;
    commentArray = [NSMutableArray arrayWithCapacity:0];
    [self loadCommentList];

    
    //列表设置
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundView:nil];
    [tableView setBackgroundColor:[UIColor colorWithHexString:@"#f1f2f6"]];
    self.prototypeCell  = [self.tableView dequeueReusableCellWithIdentifier:@"GoodsCommentCell"];
    
    [commentButton addTarget:self action:@selector(loadByType:) forControlEvents:UIControlEventTouchUpInside];
    [askButton addTarget:self action:@selector(loadByType:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) loadCommentList{
    if(page == 1){
        [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    }
    if(nodataLabel != nil){
        nodataLabel.hidden = YES;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!comment.do?id=%d&type=%d&page=%d", goods_id, type, page]];
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
                           
                           for (NSDictionary *data in dataArray) {
                               [commentArray addObject:data];
                           }
                           [tableView reloadData];
                           if(page == 1){
                               [SVProgressHUD dismiss];
                           }
                           
                           __weak __typeof(self) weakSelf = self;
                           if(self.tableView.footer == nil){
                               self.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                                   page++;
                                   [weakSelf loadCommentList];
                               }];
                           }else{
                               [self.tableView.footer endRefreshing];
                           }
                           
                       });
                   });
}


- (void) loadByType:(UIButton *) sender{
    page = 1;
    [commentArray removeAllObjects];
    if(sender == commentButton){
        [commentButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [askButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        type = 1;
    }else{
        [commentButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [askButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        type = 2;
    }
    [self loadCommentList];
    
}

/**
 *  没有数据时显示
 */
- (void) showNoData{
    if(nodataLabel == nil){
        nodataLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 115, kScreenWidth, kScreenHeight)];
        [nodataLabel setText: @"抱歉，暂时没有评论内容"];
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
    navView.backgroundColor = [UIColor colorWithHexString:@"#FFFFFF"];
    [super setBorderWithView:navView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
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
    return commentArray.count;
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
    static NSString *cellIdentifier = @"GoodsCommentCell";
    GoodsCommentCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    NSDictionary *comment = [commentArray objectAtIndex:[indexPath row]];
    
    if([[comment objectForKey:@"uname"] isKindOfClass:[NSString class]]){
        [cell.uname setText:[comment objectForKey:@"uname"]];
    }else{
        [cell.uname setText:@"游客"];
    }
    
    NSString *contentTxt = [comment objectForKey:@"content"];
    NSDictionary *attributeButton = @{NSFontAttributeName: [UIFont systemFontOfSize:12]};
    CGSize fontSize = [contentTxt boundingRectWithSize:CGSizeMake(MAXFLOAT,40) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributeButton context:nil].size;
    double finalHeight = fontSize.height * cell.content.numberOfLines;
    double finalWidth = cell.content.frame.size.width;    //expected width of label
    CGSize theStringSize = [contentTxt sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(finalWidth, finalHeight) lineBreakMode:cell.content.lineBreakMode];
    int newLinesToPad = (finalHeight  - theStringSize.height) / fontSize.height;
    for(int i=0; i<newLinesToPad; i++)
        contentTxt = [contentTxt stringByAppendingString:@"\n "];
    [cell.content setText:contentTxt];
    
    //头像
    if([[comment objectForKey:@"face"] isKindOfClass:[NSString class]]){
        [cell.face sd_setImageWithURL:[NSURL URLWithString:[comment objectForKey:@"face"]]
                      placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
    }else{
        cell.face.image = [UIImage imageNamed:@"my_head_default.png"];
    }
    
    //时间
    cell.time.text = [DateHelper unixtimeToString:[[comment objectForKey:@"dateline"] doubleValue] withFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    //星星
    int grade = [[comment objectForKey:@"grade"] intValue];
    UIImage *redStar = [UIImage imageNamed:@"ico_star1.png"];
    UIImage *greyStar = [UIImage imageNamed:@"ico_star2.png"];
    cell.star1.image = grade > 0 ? redStar : greyStar;
    cell.star2.image = grade > 1 ? redStar : greyStar;
    cell.star3.image = grade > 2 ? redStar : greyStar;
    cell.star4.image = grade > 3 ? redStar : greyStar;
    cell.star5.image = grade > 4 ? redStar : greyStar;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)c forRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCommentCell *cell = (GoodsCommentCell *)c;
    cell.headerView.frame = CGRectMake(cell.headerView.frame.origin.x, cell.headerView.frame.origin.y, cell.contentView.frame.size.width, cell.headerView.frame.size.height);
    [super setBorderWithView:cell.headerView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:cell.contentView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}
@end
