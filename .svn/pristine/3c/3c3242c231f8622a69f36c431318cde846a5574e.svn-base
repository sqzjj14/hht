//
//  SearchViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "SearchViewController.h"
#import "UIColor+HexString.h"
#import "SearchHistoryCell.h"
#import "SVProgressHUD.h"

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *searchView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *keyword;
- (IBAction)cancel:(id)sender;

@end

@implementation SearchViewController{
    NSMutableArray *historyArray;
}

@synthesize headerView, searchView, tableView;
@synthesize keyword;
@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];

    //搜索框设置
    searchView.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    searchView.layer.borderWidth = 0.5f;
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = 3.0;
    
    historyArray = [NSMutableArray arrayWithCapacity:0];
    
    keyword.delegate = self;
    //注册键盘响应事件方法
    [keyword addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];

    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView setBackgroundView:nil];
    [tableView setBackgroundColor:[UIColor colorWithHexString:@"#f1f2f6"]];
    
    [self loadHistory];
    
    [keyword becomeFirstResponder];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
//    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
//    gesture.numberOfTapsRequired = 1;
//    [self.view addGestureRecognizer:gesture];

}

/*
 * 载入历史记录
 */
- (void) loadHistory{
    [historyArray removeAllObjects];
    [tableView reloadData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *historySize = [defaults objectForKey:@"history_size"];
    if(historySize == nil){
        return;
    }
    for(int i = 0; i < [historySize intValue]; i++){
        if([defaults objectForKey:[NSString stringWithFormat:@"history_%d", i]] != nil){
            [historyArray addObject:[defaults objectForKey:[NSString stringWithFormat:@"history_%d", i]]];
        }
    }
    [tableView reloadData];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 25;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *_headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 25)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, kScreenWidth - 15, 25)];
    label.text = @"历史搜索";
    label.font = [UIFont fontWithName:kFontBold size:12];
    [_headerView addSubview:label];
    return _headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 45;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *_footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 45)];
    if(historyArray.count > 0){
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-200)/2, 10, 200, 30)];
        [button setTitle:@"清空历史搜索" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [button setBackgroundColor:[UIColor whiteColor]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button.layer.borderColor = [UIColor darkGrayColor].CGColor;
        button.layer.borderWidth = 0.5f;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3.0;
        [button addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
        [_footerView addSubview:button];
    }
    return _footerView;
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
    return [historyArray count];
}

/**
 *  选中行
 *
 *  @param tableView
 *  @param indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSString *historyKeyword = [historyArray objectAtIndex:indexPath.row];
    [self dismissViewControllerAnimated:NO completion:^{
        [delegate search:historyKeyword];
    }];}

/**
 *  设置cell样式
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return
 */
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *historyKeyword = [historyArray objectAtIndex:indexPath.row];
    static NSString *cellIdentifier = @"SearchHistoryCell";
    SearchHistoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.keyword.text = historyKeyword;
    [cell setBackgroundColor:[UIColor colorWithHexString:@"#f1f2f6"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)c forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    [self hidenKeyboard];
    [self search:nil];
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.keyword resignFirstResponder];
}

-(IBAction)search:(id)sender{
    if(keyword.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入要搜索的关键词！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    //保存历史
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *historySize = [defaults objectForKey:@"history_size"];
    if(historySize == nil){
        historySize = @"0";
    }
    NSMutableArray *tempArray = [NSMutableArray arrayWithCapacity:[historySize intValue]];
    for(int i = 0; i < [historySize intValue]; i++){
        if([defaults objectForKey:[NSString stringWithFormat:@"history_%d", i]] != nil){
            if(tempArray.count < 9){
                [tempArray addObject:[defaults objectForKey:[NSString stringWithFormat:@"history_%d", i]]];
            }
            [defaults removeObjectForKey:[NSString stringWithFormat:@"history_%d", i]];
        }
    }
    [tempArray insertObject:keyword.text atIndex:0];
    for(int i = 0; i < tempArray.count; i++){
        [defaults setObject:[tempArray objectAtIndex:i] forKey:[NSString stringWithFormat:@"history_%d", i]];
    }
    [defaults setObject:[NSString stringWithFormat:@"%d", (int)tempArray.count] forKey:@"history_size"];
    [defaults synchronize];
    
    [self dismissViewControllerAnimated:NO completion:^{
        [delegate search:keyword.text];
    }];
}

- (IBAction)clear:(id)sender{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *historySize = [defaults objectForKey:@"history_size"];
    if(historySize == nil){
        return;
    }
    for(int i = 0; i < [historySize intValue]; i++){
        [defaults removeObjectForKey:[NSString stringWithFormat:@"history_%d", i]];
    }
    [defaults setObject:@"0" forKey:@"history_size"];
    [defaults synchronize];
    [self loadHistory];
}

- (IBAction)cancel:(id)sender {
    [self hidenKeyboard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
