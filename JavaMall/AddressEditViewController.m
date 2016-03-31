//
//  AddressEditViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "AddressEditViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"

@interface AddressEditViewController () <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *mobileView;
@property (weak, nonatomic) IBOutlet UIView *regionView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UILabel *regionLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)back:(id)sender;

@end

@implementation AddressEditViewController{
    HttpClient *client;
    UIView *addView;
    
    UIView *pickerSelectView;
    UIView *maskView;
    UIPickerView *pickerView;
    
    NSMutableArray *provinceArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
    
    NSDictionary *provinceRegion;
    NSDictionary *cityRegion;
    NSDictionary *countyRegion;
    
}

@synthesize headerView, nameView, mobileView, regionView, addressView, titleLabel;
@synthesize name, mobile, address, regionLabel;
@synthesize addressDic;

- (void)viewDidLoad {
    [super viewDidLoad];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    client = [[HttpClient alloc] init];
    provinceArray = [NSMutableArray arrayWithCapacity:0];
    cityArray = [NSMutableArray arrayWithCapacity:0];
    countyArray = [NSMutableArray arrayWithCapacity:0];
    
    [self initSaveView];
    [self initPicker];
    
    //注册键盘响应事件方法
    [name addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [mobile addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [address addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    if(addressDic != nil){
        titleLabel.text = @"编辑收货地址";
        name.text = [addressDic objectForKey:@"name"];
        mobile.text = [addressDic objectForKey:@"mobile"];
        address.text = [addressDic objectForKey:@"addr"];
        regionLabel.text = [[[addressDic objectForKey:@"province"] stringByAppendingString:[addressDic objectForKey:@"city"]] stringByAppendingString:[addressDic objectForKey:@"region"]];
        provinceRegion = [NSMutableDictionary dictionaryWithCapacity:0];
        [provinceRegion setValue:[addressDic objectForKey:@"province_id"] forKey:@"region_id"];
        [provinceRegion setValue:[addressDic objectForKey:@"province"] forKey:@"local_name"];
        
        cityRegion = [NSMutableDictionary dictionaryWithCapacity:0];
        [cityRegion setValue:[addressDic objectForKey:@"city_id"] forKey:@"region_id"];
        [cityRegion setValue:[addressDic objectForKey:@"city"] forKey:@"local_name"];
        
        countyRegion = [NSMutableDictionary dictionaryWithCapacity:0];
        [countyRegion setValue:[addressDic objectForKey:@"region_id"] forKey:@"region_id"];
        [countyRegion setValue:[addressDic objectForKey:@"region"] forKey:@"local_name"];
    }

    
    //tap手势
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectRegion:)];
    [tapGesture setNumberOfTapsRequired:1];
    [regionView addGestureRecognizer:tapGesture];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];

    
    [self loadData:0 type:0];

}

- (void) loadData:(int) parentId type:(int)_type{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    switch (_type) {
        case 0:
            [provinceArray removeAllObjects];
            [cityArray removeAllObjects];
            [countyArray removeAllObjects];
            break;
        case 1:
            [cityArray removeAllObjects];
            [countyArray removeAllObjects];
            break;
        case 2:
            [countyArray removeAllObjects];
            break;
        default:
            break;
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/region!list.do?parentid=%d", parentId]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *data = [result objectForKey:@"data"];
                           
                           if(data == nil){
                               [SVProgressHUD dismiss];
                               return;
                           }
                           
                           switch (_type) {
                               case 0:
                                   [provinceArray addObjectsFromArray:[data objectForKey:@"list"]];
                                   break;
                               case 1:
                                   [cityArray addObjectsFromArray:[data objectForKey:@"list"]];
                                   break;
                               case 2:
                                   [countyArray addObjectsFromArray:[data objectForKey:@"list"]];
                                   break;
                                   
                               default:
                                   break;
                           }
                           
                           [pickerView reloadComponent:_type];
                           if(_type == 0){
                               if(provinceArray.count > 0){
                                   NSDictionary *provice = [provinceArray objectAtIndex:0];
                                   
                                   //根据所选的省 如广东的region_id为20，再请求出市的[data]
                                   //[self loadData:[[provice objectForKey:@"region_id"] intValue] type:1];
                                   [self loadData:20 type:1];
                                   [SVProgressHUD dismiss];
                               }
                           }
                           if(_type == 1){
                               if(cityArray.count > 0){
                                   NSDictionary *city = [cityArray objectAtIndex:0];
                                   [self loadData:[[city objectForKey:@"region_id"] intValue] type:2];
                               }else{
                                   [SVProgressHUD dismiss];
                               }
                           }
                           if(_type == 2){
                               [SVProgressHUD dismiss];
                           }
                       });
                   });
}

- (void) initSaveView{
    addView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    [addView setBackgroundColor:[UIColor whiteColor]];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 250) / 2, 5, 250, 34)];
    [addButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [addButton setTitle:@"保存" forState:UIControlStateNormal];
    [addButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [addButton addTarget:self action:@selector(OK:) forControlEvents:UIControlEventTouchUpInside];
    [addView addSubview:addButton];
    
    [self.view addSubview:addView];
}


/*
 * 创建省市县选择器
 */
- (void) initPicker{
    
    //遮罩层
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePicker)]];
    
    pickerSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 240)];
    pickerSelectView.backgroundColor = [UIColor whiteColor];
    
    //操作区
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 20)];
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(hidePicker) forControlEvents:UIControlEventTouchUpInside];
    [operateView addSubview:cancelBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40, 10, 30, 20)];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [okBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(selectRegionOK:) forControlEvents:UIControlEventTouchUpInside];
    [super setBorderWithView:operateView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [operateView addSubview:okBtn];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 200)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    [pickerSelectView addSubview:pickerView];
    
    
    [pickerSelectView addSubview:operateView];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:nameView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:mobileView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:regionView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:addressView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

#pragma mark - UIPicker Delegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        //return provinceArray.count;
        return 1;
    } else if (component == 1) {
        return cityArray.count;
    } else {
        return countyArray.count;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (component == 0) {
        NSDictionary *province = [provinceArray objectAtIndex:19];
        return [province objectForKey:@"local_name"];
    } else if (component == 1) {
        NSDictionary *city = [cityArray objectAtIndex:row];
        return [city objectForKey:@"local_name"];
    } else {
        NSDictionary *county = [countyArray objectAtIndex:row];
        return [county objectForKey:@"local_name"];
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return kScreenWidth / 3;
}

- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //选中对应的省份，重载pickerView刷新省市。
    //    if (component == 0) {
    //        NSDictionary *province = [provinceArray objectAtIndex:row];
    //        [self loadData:[[province objectForKey:@"region_id"] intValue] type:1];
    //        [_pickerView selectedRowInComponent:1];
    //        [_pickerView selectedRowInComponent:2];
    //        return;
    //    }
    if (component == 1) {
        NSDictionary *city = [cityArray objectAtIndex:row];
        [self loadData:[[city objectForKey:@"region_id"] intValue] type:2];
        return;
    }
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
//    UILabel *myView = nil;
//    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)];
//    myView.textAlignment = NSTextAlignmentCenter;
//    myView.font = [UIFont systemFontOfSize:14];
//    myView.backgroundColor = [UIColor clearColor];
//    if (component == 0) {
//        NSDictionary *province = [provinceArray objectAtIndex:row];
//        myView.text = [province objectForKey:@"local_name"];
//    } else if (component == 1) {
//        NSDictionary *city = [cityArray objectAtIndex:row];
//        myView.text = [city objectForKey:@"local_name"];
//    } else {
//        NSDictionary *county = [countyArray objectAtIndex:row];
//        myView.text = [county objectForKey:@"local_name"];
//    }
//    return myView;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == name) {
        [self.mobile becomeFirstResponder];
    }else if (sender == mobile) {
        [self.address becomeFirstResponder];
    }else if (sender == address){
        [self hideKeyboard];
        [self OK:nil];
    }
}

//隐藏键盘的方法
-(void)hideKeyboard{
    [self.name resignFirstResponder];
    [self.mobile resignFirstResponder];
    [self.address resignFirstResponder];
}

/*
 * 隐藏选择区域
 */
- (void)hidePicker {
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 0;
        pickerSelectView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 240);
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [pickerSelectView removeFromSuperview];
        addView.hidden = NO;
    }];
}

/**
 *  选择区域
 *
 *  @param gesture
 */
- (void)selectRegion:(UITapGestureRecognizer *)gesture{
    [self hideKeyboard];
    
    maskView.alpha = 0;
    [self.view addSubview:maskView];
    [self.view addSubview:pickerSelectView];
    addView.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 0.3;
        pickerSelectView.frame = CGRectMake(0, kScreenHeight - 240, kScreenWidth, 240);
    }];
    
}

/*
 * 选择区域完成
 */
- (IBAction)selectRegionOK:(id)sender {
    provinceRegion = [provinceArray objectAtIndex:[pickerView selectedRowInComponent:0]];
    cityRegion = [cityArray objectAtIndex:[pickerView selectedRowInComponent:1]];
    countyRegion = [countyArray objectAtIndex:[pickerView selectedRowInComponent:2]];
    NSString *region = @"";
    if(provinceRegion != nil){
         // region = [region stringByAppendingString:[provinceRegion objectForKey:@"local_name"]];
      region = @"广东";
    }
    if(cityRegion != nil){
        region = [region stringByAppendingString:[cityRegion objectForKey:@"local_name"]];
    }
    if(countyRegion != nil){
        region = [region stringByAppendingString:[countyRegion objectForKey:@"local_name"]];
    }
    regionLabel.text = region;
    [self hidePicker];
}

/*
 * 确定
 */
- (IBAction) OK:(id)sender{
    if(name.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"收货人姓名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(mobile.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"手机号码不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(name.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"收货人姓名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(provinceRegion == nil || cityRegion == nil || countyRegion == nil){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请选择所在地区！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(address.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"详细地址不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在保存..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
                       [params setValue:name.text forKey:@"name"];
                      // [params setValue:[provinceRegion objectForKey:@"region_id"]
                                 //forKey:@"province_id"];
                       [params setValue:@"20" forKey:@"province_id"];
                       [params setValue:[cityRegion objectForKey:@"region_id"] forKey:@"city_id"];
                       [params setValue:[countyRegion objectForKey:@"region_id"] forKey:@"region_id"];
                       [params setValue:address.text forKey:@"addr"];
                       [params setValue:mobile.text forKey:@"mobile"];
                       
                       NSString *action = addressDic == nil ? @"add" : @"edit";
                       if(addressDic != nil){
                           [params setValue:[addressDic objectForKey:@"addr_id"] forKey:@"addr_id"];
                       }
                       NSString *content = [client post:[BASE_URL stringByAppendingFormat:@"/api/mobile/address!%@.do", action] withData:params];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"保存失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           //保存成功
                           addressDic = [NSMutableDictionary dictionaryWithDictionary:[[result objectForKey:@"data"] objectForKey:@"address"]];
                           [[NSNotificationCenter defaultCenter] postNotificationName:nEditAddress object:nil userInfo:addressDic];
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });

}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
