//
//  CouponViewController.m
//  JavaMall
//
//  Created by gang liu on 16/4/21.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "CouponViewController.h"
#import "Defines.h"
#import "CouponCell.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"

#import "CheckoutViewController.h"

@interface CouponViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataSource;
@property (weak, nonatomic) IBOutlet UIView *headview;

@property (weak, nonatomic) IBOutlet UIView *selectView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;
@property (weak, nonatomic) IBOutlet UIButton *yesBtn;
@property (weak, nonatomic) IBOutlet UILabel *noCouponLabel;
@property (weak, nonatomic) IBOutlet UIButton *explainBtn;
@end

@implementation CouponViewController{
    HttpClient *client;
}

- (void)viewDidLoad {
    [super viewDidLoad];
     _dataSource = [[NSMutableArray alloc]init];
    UIView *statusview = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.view.frame.size.width, 20)];
    statusview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:statusview];
    
    _headview.backgroundColor = [UIColor whiteColor];
    client = [[HttpClient alloc]init];
    _yesBtn.selected = NO;
    [self getHttp];
    
    
    if (!_ispaying) {
        [_selectView removeFromSuperview];
    }
    else{
        [self initleftButton];
    }
    
   
    
}
-(void)getHttp{
    NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/shop/bonus!getMemberBonus2.do"]];
    if ([content length] == 0 || content == nil) {
        return;
    }
    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
    if ([[result objectForKey:@"result"]intValue] == 0) {
        return;
    }
    else{
        NSDictionary *data = [result objectForKey:@"data"];
        if (data == nil) {
            return;
        }
        for (NSArray *arr in data) {
            [_dataSource addObject:arr];
            [self initTableView];
        }
    }
    
}
-(void)initleftButton{
    UIButton *useBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    useBtn.frame = CGRectMake(10, 5 + 64, 100, 20);
    [useBtn setTitle:@"使用红包" forState:UIControlStateNormal];
    [useBtn setTitleColor:[UIColor colorWithRed:75/255.0 green:75/255.0 blue:75/255.0 alpha:1] forState:UIControlStateNormal];
    [useBtn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    useBtn.titleLabel.font = [UIFont fontWithName:kFontBold size:13.f];
    //useBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    useBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [useBtn addTarget:self action:@selector(useCoupon:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:useBtn];
}
-(void)initTableView{
    self.view.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];

    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(10, 64 + 30, self.view.frame.size.width - 20, self.view.frame.size.height - 64 -30)];
    
    [_tableView registerNib:[UINib nibWithNibName:@"CouponCell" bundle:nil] forCellReuseIdentifier:@"CouponCell"];
    [_tableView setSeparatorColor:[UIColor clearColor]];
    _tableView.delegate = self;
    _tableView.dataSource =self;
    [self.view addSubview:_tableView];
    
    if (_ispaying) {
        [self.view bringSubviewToFront:_selectView];
    }
    
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CouponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CouponCell"];
    NSMutableDictionary *couponModel = _dataSource[indexPath.section];
    cell.name.text = [couponModel objectForKey:@"name"];
    cell.remark.text = [couponModel objectForKey:@"remark"];
    cell.time.text = [couponModel objectForKey:@"time"];
    [cell.image sd_setImageWithURL:[NSURL URLWithString:[couponModel objectForKey:@"imageUrl"]]];
    
    //里数据！
    cell.type_id = [couponModel objectForKey:@"type_id"];
    cell.coupon_id = [couponModel objectForKey:@"coupon_id"];
    cell.price = [couponModel objectForKey:@"price"];
    cell.limitprice = [couponModel objectForKey:@"limitprice"];
     
    
    cell.backgroundColor = [UIColor whiteColor];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CouponCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (_ispaying) {
        if ([_amount floatValue] < [cell.limitprice floatValue]) {
            [SVProgressHUD setErrorImage:nil];
            [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"金额未满%@元，无法使用该类型代金劵",cell.limitprice] maskType:SVProgressHUDMaskTypeBlack];
            return;
        }
        //这里发送通知回调_couponID
        NSDictionary *passDIC = _dataSource[indexPath.section];
        [[NSNotificationCenter defaultCenter]postNotificationName:nSelectCoupon object:nil userInfo:passDIC];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    return;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    footview.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
    return footview;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 20.f;
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)unUseCoupon:(id)sender {
    [[NSNotificationCenter defaultCenter]postNotificationName:nSelectCoupon object:nil userInfo:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark Helper
- (void)useCoupon:(UIButton*)btn{
    
}


@end
