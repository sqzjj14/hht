//
//  AddressViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "AddressViewController.h"
#import "UIColor+HexString.h"
#import "AddressCell.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "AddressEditViewController.h"

@interface AddressViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//保存def_Btn Tag用的数组
@property (nonatomic,strong) NSMutableArray *BtnArr;
//选中的def_Btn tag
@property (nonatomic,assign) NSInteger selectedBtnTag;
//是否是vip客服
@property (nonatomic,assign) NSInteger VIPSelected;
- (IBAction)back:(id)sender;

@end

@implementation AddressViewController{
    NSMutableArray *addresses;
    HttpClient *client;
    UIColor *bgcolor;
}

@synthesize headerView, tableView;
@synthesize type;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    client = [[HttpClient alloc] init];
    addresses = [NSMutableArray arrayWithCapacity:0];
    
    bgcolor = [UIColor colorWithHexString:@"#eff3f6"];
    
    _BtnArr = [[NSMutableArray alloc]init];
    [_BtnArr removeAllObjects];
    
    //列表设置
    if([type isEqualToString:@"manage"]){
        tableView.rowHeight = 117;
    }else{
        tableView.rowHeight = 74;
    }
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = bgcolor;
    
    //绑定通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editCompletion:) name:nEditAddress object:nil];
    [self initAddView];
    [self loadAddressList];
}

/**
 *  编辑完成时重新载入列表
 *
 *  @param notification
 */
-(void)editCompletion:(NSNotification*)notification {
    [self loadAddressList];
}

/**
 *  初始化新建地址视图  （也就是下面的新建按钮而已）
 */
- (void) initAddView{
    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [addView setBackgroundColor:bgcolor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, 5, 150, 34)];
    [addButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [addButton setTitle:@"+ 新建地址" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
   // [addView addSubview:addButton];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 44, 0);
    tableView.contentInset = insets;
    
    //[self.view addSubview:addView];

}

/**
 *  载入地址列表
 */
- (void) loadAddressList{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    [addresses removeAllObjects];
    [tableView reloadData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/shop/memberAddress!list.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setInfoImage:nil];
                               [SVProgressHUD showInfoWithStatus:@"载入失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"未登录或登录已过期，请重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                               [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                               return;
                           }
                           
                           NSDictionary *data = [result objectForKey:@"data"];
                           if(data == nil){
                               [SVProgressHUD setInfoImage:nil];
                               [SVProgressHUD showInfoWithStatus:@"载入失败，请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSArray *addressList = [data objectForKey:@"addressList"];
                           for (NSDictionary *address in addressList) {
                               [addresses addObject:address];
                               // addresses是一个可变数组，做数据源的吧
                           }
                           [tableView reloadData];
                           
                       });
                   });
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
    return addresses.count;
}

/**
 *  设置cell样式
 *
 *  @param tableView
 *  @param indexPath
 *
 *  @return
 */
#pragma mark cellForRowAtIndexPath
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *address = [addresses objectAtIndex:indexPath.row];
    
    //存储defBtn的tag
    NSString *defTag = [NSString stringWithFormat:@"%d",indexPath.row + 10];
    [_BtnArr addObject:defTag];
    
    
    NSString *cellIdentifier = @"AddressCell2";
    if([type isEqualToString:@"manage"]){
        cellIdentifier = @"AddressCell";
    }else{
        cellIdentifier = @"AddressCell2";
    }
    
    
    AddressCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.name.text = [address objectForKey:@"name"];
    cell.mobile.text = [address objectForKey:@"mobile"];
    cell.address.text = [address objectForKey:@"addr"];
    cell.editBtn.tag = indexPath.row;
    [cell.editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    // --------changgeDefault
    
    cell.defaultBtn.tag = indexPath.row + 10;
    
    [cell.defaultBtn addTarget:self action:@selector(changeDefault:) forControlEvents:UIControlEventTouchUpInside];
    
    //  -------checkout----------
    if([cellIdentifier isEqualToString:@"AddressCell2"]){
        if([[address objectForKey:@"def_addr"] intValue] == 1){
            _selectedBtnTag = indexPath.row + 10;
        }else{
            cell.defaultBtn.backgroundColor = [UIColor lightGrayColor];
        }
    }
    
    //  －－－－PersonEdit－－－－－
    if([cellIdentifier isEqualToString:@"AddressCell"]){

        if([[address objectForKey:@"def_addr"] intValue] == 1){
           [cell.defaultBtn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateNormal];
            _selectedBtnTag = indexPath.row + 10;
        }else{
           [cell.defaultBtn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
        }

    }
    
    // --------VIP------------
    if ([[address objectForKey:@"VIP"]integerValue] == 1) {
        //设置金色头像和手机
        cell.userImage.image = [UIImage imageNamed:@"goldUser"];
        cell.userImage.image = [UIImage imageNamed:@"goldMobile"];
        //金头像特别的编辑模式
        //记录vip的tag和 btn tag对比
        cell.editBtn.tag = 10000;
    }
    
    return cell;
}
-(void)changeDefault:(UIButton*)btn{
    if (btn.tag == _selectedBtnTag) {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"已是默认地址" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    else{
            //getHttp
            NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/address!list.do"]];
            
                [SVProgressHUD dismiss];
                
                if([content length] == 0){
                    [SVProgressHUD setInfoImage:nil];
                    [SVProgressHUD showInfoWithStatus:@"默认地址修改失败" maskType:SVProgressHUDMaskTypeBlack];
                    return;
                }
                
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                
                if([[result objectForKey:@"result"] intValue] == 0){
                    [SVProgressHUD setErrorImage:nil];
                    [SVProgressHUD showErrorWithStatus:@"未登录或登录已过期，请重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                    [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                    return;
                }
            if ([[result objectForKey:@"result"]intValue] == 1) {
                [SVProgressHUD setErrorImage:nil];
                [SVProgressHUD showErrorWithStatus:@"默认地址已更变" maskType:SVProgressHUDMaskTypeBlack];
                
                for (NSString *tagStr in _BtnArr) {
                    UIButton *otherBtn = [self.view viewWithTag:[tagStr integerValue]];
                    
                    //根据编辑模式决定
                    if([type isEqualToString:@"manage"]){
                        [otherBtn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
                        [btn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateNormal];
                    }else{
                        otherBtn.backgroundColor = [UIColor lightGrayColor];
                        btn.backgroundColor = [UIColor colorWithRed:190/255.0 green:20/255.0 blue:44/255.0 alpha:1];
                    }

                    
                }
                //记录新的选中tag
                _selectedBtnTag = btn.tag;
            }
        }
}
/**
 *  添加地址
 *
 *  @param sender
 */
- (void) add:(id)sender{
    [self presentViewController:[super controllerFromMainStroryBoard:@"AddressEdit"] animated:YES completion:nil];
}

/**
 *  编辑选中地址
 *
 *  @param sender
 */
- (void) edit:(id)sender{
    UIButton *editBtn = (UIButton *)sender;
    NSDictionary *address = [addresses objectAtIndex:editBtn.tag];
    
    AddressEditViewController *addressEditViewController = (AddressEditViewController *)[super controllerFromMainStroryBoard:@"AddressEdit"];
    addressEditViewController.addressDic = [NSMutableDictionary dictionaryWithDictionary:address];
    
    //VIP
    if (editBtn.tag == 10000) {
        addressEditViewController.type = @"VIP";
    }
    
    [self presentViewController:addressEditViewController animated:YES completion:nil];
}

/**
 *  删除选中地址
 *
 *  @param sender
 */
- (void)delete:(id)sender{
    UIButton *deleteBtn = (UIButton *)sender;
    
    [SVProgressHUD setErrorImage:nil];
    [SVProgressHUD showErrorWithStatus:@"基地地址无法删除！" maskType:SVProgressHUDMaskTypeBlack];
    return;
//    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您确认要删除这个地址吗？"
//                                                             delegate:self
//                                                    cancelButtonTitle:@"取消"
//                                               destructiveButtonTitle:@"确定"
//                                                    otherButtonTitles:nil
//                                  ];
//    actionSheet.tag = deleteBtn.tag;
//    [actionSheet showInView:self.view];
}

/**
 *  执行删除确认操作
 *
 *  @param actionSheet
 *  @param buttonIndex
 */
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=[actionSheet cancelButtonIndex]){
        NSDictionary *address = [addresses objectAtIndex:actionSheet.tag];
    
        [SVProgressHUD showWithStatus:@"正在删除..." maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/address!delete.do?addr_id=%d", [[address objectForKey:@"addr_id"] intValue]] ];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               
                               if([content length] == 0){
                                   [SVProgressHUD setErrorImage:nil];
                                   [SVProgressHUD showErrorWithStatus:@"删除失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                                   return;
                               }
                               
                               NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                               if([[result objectForKey:@"result"] intValue] == 0){
                                   [SVProgressHUD setErrorImage:nil];
                                   [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                                   return;
                               }
                               
                               [addresses removeObjectAtIndex:actionSheet.tag];
                               [tableView reloadData];
                           });
                       });
    }
}

/**
 *  显示cell时设置下划线
 *
 *  @param tableView
 *  @param c
 *  @param indexPath
 */
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)c forRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressCell *cell = (AddressCell *)c;
    [super setBorderWithView:cell.contentView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

/**
 *  选择地址
 *
 *  @param tableView
 *  @param indexPath
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([type isEqualToString:@"manage"] == NO){
        NSDictionary *address = [addresses objectAtIndex:indexPath.row];
        [[NSNotificationCenter defaultCenter] postNotificationName:nSelectAddress object:nil userInfo:address];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if ([type isEqualToString:@"manage"] == YES) {
        //defaut Btn ~?
    }
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

/**
 *  后退
 *
 *  @param sender
 */
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
