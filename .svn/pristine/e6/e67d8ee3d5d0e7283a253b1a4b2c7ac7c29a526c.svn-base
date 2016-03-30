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
 *  初始化新建地址视图
 */
- (void) initAddView{
    UIView *addView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [addView setBackgroundColor:bgcolor];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, 5, 150, 34)];
    [addButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [addButton setTitle:@"+ 新建地址" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [addButton addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:addButton];
    
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, 44, 0);
    tableView.contentInset = insets;
    
    [self.view addSubview:addView];

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
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/address!list.do"]];
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
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *address = [addresses objectAtIndex:indexPath.row];
    NSString *cellIdentifier = @"AddressCell2";
    if([type isEqualToString:@"manage"]){
        cellIdentifier = @"AddressCell";
    }else{
        cellIdentifier = @"AddressCell2";
        if([[address objectForKey:@"def_addr"] intValue] == 1){
            cellIdentifier = @"AddressCell2_Default";
        }
    }
    
    AddressCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.name.text = [address objectForKey:@"name"];
    cell.mobile.text = [address objectForKey:@"mobile"];
    cell.address.text = [address objectForKey:@"addr"];
    cell.editBtn.tag = indexPath.row;
    [cell.editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    cell.deleteBtn.tag = indexPath.row;
    [cell.deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    cell.defaultBtn.hidden = NO;
    if([cellIdentifier isEqualToString:@"AddressCell"]){
        if([[address objectForKey:@"def_addr"] intValue] == 1){
            cell.defaultBtn.hidden = NO;
//            [cell.defaultBtn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateNormal];
        }else{
            cell.defaultBtn.hidden = YES;
//            [cell.defaultBtn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
        }
    }
    return cell;
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
    [self presentViewController:addressEditViewController animated:YES completion:nil];
}

/**
 *  删除选中地址
 *
 *  @param sender
 */
- (void)delete:(id)sender{
    UIButton *deleteBtn = (UIButton *)sender;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您确认要删除这个地址吗？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"确定"
                                                    otherButtonTitles:nil
                                  ];
    actionSheet.tag = deleteBtn.tag;
    [actionSheet showInView:self.view];
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
