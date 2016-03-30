//
//  UpdataViewController.m
//  JavaMall
//
//  Created by 王旭 on 16/3/6.
//  Copyright © 2016年 Enation. All rights reserved.
//

#import "PersonEditViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"

@interface PersonEditViewController ()
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *sexView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UIView *postView;
@property (weak, nonatomic) IBOutlet UIView *mobileView;
@property (weak, nonatomic) IBOutlet UIView *liveView;
@property (weak, nonatomic) IBOutlet UIView *telView;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UILabel *labSex;
@property (weak, nonatomic) IBOutlet UILabel *labDate;
@property (weak, nonatomic) IBOutlet UILabel *labLive;
@property (weak, nonatomic) IBOutlet UITextField *txtAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtPost;
@property (weak, nonatomic) IBOutlet UITextField *txtMobile;
@property (weak, nonatomic) IBOutlet UITextField *txtTel;
@property (weak, nonatomic) IBOutlet UIButton *btnUp;
@property (weak, nonatomic) IBOutlet UIButton *btnBack;
@property (weak, nonatomic) IBOutlet UIScrollView *upScrollView;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation PersonEditViewController{
    
    HttpClient *client;
    
    NSArray *sexArray;
    
    UIView *pickerSelectView;
    UIView *maskView;
    UIPickerView *pickerView;
    
    UIView *livePickerSelectView;
    UIView *liveMaskView;
    UIPickerView *livePickerView;
    
    UIView *datePickerSelectView;
    UIView *dateMaskView;
    UIDatePicker *datePickerView;
    
    int getSex;
    NSDate *birthday;
    
    NSMutableArray *provinceArray;
    NSMutableArray *cityArray;
    NSMutableArray *countyArray;
    
    NSDictionary *provinceRegion;
    NSDictionary *cityRegion;
    NSDictionary *countyRegion;
    
    
    NSString *identification;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self viewDidLayoutSubviews];
    
    sexArray = [[NSArray alloc]initWithObjects:@"男",@"女",nil];
    
    client = [[HttpClient alloc] init];
    
    
    provinceArray = [NSMutableArray arrayWithCapacity:0];
    cityArray = [NSMutableArray arrayWithCapacity:0];
    countyArray = [NSMutableArray arrayWithCapacity:0];
    
    [self initPicker];
    [self initDatePicker];
    [self initLivePicker];
    
    _txtMobile.delegate = self;
    _txtTel.delegate = self;
    _txtName.delegate = self;
    _txtAddress.delegate = self;
    _txtPost.delegate = self;
    
    UIImage *registerBg = [UIImage imageNamed:@"Button_A.png"];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    registerBg = [registerBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [self.btnUp setBackgroundImage:registerBg forState:UIControlStateNormal];
    [self.btnUp setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    //给后退按钮添加事件
    [self.btnBack addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    //给性别view添加手势
    UITapGestureRecognizer *sexGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sexClick)];
    [sexGesture setNumberOfTapsRequired:1];
    [self.sexView addGestureRecognizer:sexGesture];
    
    //给生日添加手势
    UITapGestureRecognizer *dateGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dateClick)];
    [dateGesture setNumberOfTapsRequired:1];
    [self.dateView addGestureRecognizer:dateGesture];
    
    //给居住地添加手势
    UITapGestureRecognizer *liveGasture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(liveClick)];
    [liveGasture setNumberOfTapsRequired:1];
    [self.liveView addGestureRecognizer:liveGasture
     ];
    
    [self.btnUp addTarget:self action:@selector(btnUpdate:) forControlEvents:UIControlEventTouchUpInside];
    
    //添加return按下后事件
    [self.txtName addTarget:self action:@selector(returnEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.txtAddress addTarget:self action:@selector(returnEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.txtPost addTarget:self action:@selector(returnEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.txtMobile addTarget:self action:@selector(returnEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.txtTel addTarget:self action:@selector(returnEnd:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    [self loadData:0 type:0];
    [self loadWebData];
}

-(IBAction)returnEnd:(id)sender
{
    if (sender == self.txtName)
    {
        [self.txtAddress becomeFirstResponder];
    }else if (sender == self.txtAddress){
        [self.txtPost becomeFirstResponder];
    }else if (sender == self.txtPost){
        [self.txtMobile becomeFirstResponder];
    } else if (sender == self.txtMobile){
        [self.txtTel becomeFirstResponder];
    } else if (sender == self.txtTel){
        [self hidenKeyboard];
        [self btnUpdate:nil];
    }
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:_txtMobile] || [textField isEqual:_txtTel] || [textField isEqual:_txtPost])
    {
        [self sorollerPosition:YES];
    }
    else
    {
        [self sorollerPosition:NO];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    [self sorollerPosition:NO];
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.txtName resignFirstResponder];
    [self.txtAddress resignFirstResponder];
    [self.txtPost resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtTel resignFirstResponder];
    [self sorollerPosition:NO];
}

-(void)sorollerPosition:(BOOL) isPoint{
    if (isPoint){
        CGPoint position = CGPointMake(0, 222);
        [self.upScrollView setContentOffset:position animated:YES];
    }else{
        CGPoint position = CGPointMake(0, 0);
        [self.upScrollView setContentOffset:position animated:YES];
    }
}



- (void) viewDidLayoutSubviews{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#e7e8ee"];
    _headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];

    [super setBorderWithView:self.nameView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.sexView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.dateView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.liveView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.addressView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.postView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.mobileView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.telView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:self.telView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void) initPicker{
    //遮罩层
    maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = 0;
    [maskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickers)]];
    
    pickerSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 240)];
    pickerSelectView.backgroundColor = [UIColor whiteColor];
    
    //操作区
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 20)];
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(hidePickers) forControlEvents:UIControlEventTouchUpInside];
    
    [operateView addSubview:cancelBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40, 10, 30, 20)];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [okBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [okBtn addTarget:self action:@selector(selectRegionOk:) forControlEvents:UIControlEventTouchUpInside];
    [super setBorderWithView:operateView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [operateView addSubview:okBtn];
    
    pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 200)];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    
    [pickerSelectView addSubview:pickerView];
    [pickerSelectView addSubview:operateView];
}


-(IBAction)btnUpdate:(id)sender{
    if(_txtName.text.length == 0)
    {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"真实姓名不能为空" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if(![self isPureInt:_txtPost.text] && _txtPost.text.length >0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"邮编只可为数字！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if (_txtPost.text.length !=6 && _txtPost.text.length >0)
    {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"邮编应为6位数字！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if (_txtMobile.text.length ==0 && _txtTel.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"电话和手机必须填写一项！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if(![self isPureInt:_txtMobile.text] && _txtMobile.text.length >0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"手机只可以是数字！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if (_txtMobile.text.length !=11 && _txtMobile.text.length >0)
    {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"手机应为11位数字！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在修改资料..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       
                       NSMutableDictionary *nsPost = [[NSMutableDictionary alloc] init];
                       [nsPost setObject:_txtName.text forKey:@"member.name"];
                       [nsPost setObject:[NSString stringWithFormat:@"%d",getSex] forKey:@"member.sex"];
                       if(birthday != nil){
                           NSString *birthdayStr =[NSString stringWithFormat:@"%d", (long)[birthday timeIntervalSince1970]];
                           [nsPost setObject:birthdayStr forKey:@"member.birthday"];
                       }else{
                           [nsPost setObject:@"0" forKey:@"member.birthday"];
                       }
                       if(provinceRegion != nil){
                           [nsPost setValue:[provinceRegion objectForKey:@"region_id"] forKey:@"province_id"];
                           [nsPost setObject:[provinceRegion objectForKey:@"local_name"] forKey:@"member.province"];
                       }
                       
                       if(cityRegion != nil){
                           [nsPost setValue:[cityRegion objectForKey:@"region_id"] forKey:@"city_id"];
                           [nsPost setObject:[cityRegion objectForKey:@"local_name"] forKey:@"member.city"];
                       }
                       
                       if(countyRegion != nil){
                           [nsPost setValue:[countyRegion objectForKey:@"region_id"] forKey:@"region_id"];
                           [nsPost setObject:[countyRegion objectForKey:@"local_name"] forKey:@"member.region"];
                       }
                       
                       [nsPost setObject:_txtAddress.text forKey:@"member.address"];
                       [nsPost setObject:_txtPost.text forKey:@"member.zip"];
                       [nsPost setObject:_txtMobile.text forKey:@"member.mobile"];
                       [nsPost setObject:_txtTel.text forKey:@"member.tel"];
                       
                       NSString *content = [client post:[BASE_URL stringByAppendingString:@"/api/mobile/member!save.do"] useEncoding:NSUTF8StringEncoding withData:nsPost];
                       
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"修改资料失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           [SVProgressHUD setSuccessImage:nil];
                           [SVProgressHUD showSuccessWithStatus:@"修改资料成功！" maskType:SVProgressHUDMaskTypeBlack];
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });
    
    
    
}

//判断是否为整形：
- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

- (void) initLivePicker{
    
    //遮罩层
    liveMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    liveMaskView.backgroundColor = [UIColor blackColor];
    liveMaskView.alpha = 0;
    [liveMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickersLive)]];
    
    livePickerSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 240)];
    livePickerSelectView.backgroundColor = [UIColor whiteColor];
    
    //操作区
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 20)];
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(hidePickersLive) forControlEvents:UIControlEventTouchUpInside];
    
    [operateView addSubview:cancelBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40, 10, 30, 20)];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [okBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [okBtn addTarget:self action:@selector(selectRegionOk:) forControlEvents:UIControlEventTouchUpInside];
    [super setBorderWithView:operateView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [operateView addSubview:okBtn];
    
    
    
    livePickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, kScreenWidth, 200)];
    livePickerView.delegate = self;
    livePickerView.dataSource = self;
    
    [livePickerSelectView addSubview:livePickerView];
    [livePickerSelectView addSubview:operateView];
}

- (void) initDatePicker{
    
    //遮罩层
    dateMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, kScreenWidth, kScreenHeight - 64)];
    dateMaskView.backgroundColor = [UIColor blackColor];
    dateMaskView.alpha = 0;
    [dateMaskView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickerDate)]];
    
    datePickerSelectView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 240)];
    datePickerSelectView.backgroundColor = [UIColor whiteColor];
    
    //操作区
    UIView *operateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40)];
    
    UIButton *cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 30, 20)];
    [cancelBtn setTitle:@"关闭" forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    [cancelBtn addTarget:self action:@selector(hidePickerDate) forControlEvents:UIControlEventTouchUpInside];
    
    [operateView addSubview:cancelBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth - 40, 10, 30, 20)];
    [okBtn setTitle:@"确定" forState:UIControlStateNormal];
    okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [okBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(selectRegionOKDate:) forControlEvents:UIControlEventTouchUpInside];
    [super setBorderWithView:operateView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [operateView addSubview:okBtn];
    
    
    datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0,40,kScreenWidth,200)];
    datePickerView.datePickerMode = UIDatePickerModeDate;
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zh_CN"];
    datePickerView.locale = locale;
    
    [datePickerSelectView addSubview:datePickerView];
    
    [datePickerSelectView addSubview:operateView];
}

-(IBAction)selectRegionOk:(id)sender{
    
    if ([identification isEqual:@"live"]){
        provinceRegion = [provinceArray objectAtIndex:[livePickerView selectedRowInComponent:0]];
        cityRegion = [cityArray objectAtIndex:[livePickerView selectedRowInComponent:1]];
        countyRegion = [countyArray objectAtIndex:[livePickerView selectedRowInComponent:2]];
        NSString *region = @"";
        if(provinceRegion != nil){
            region = [region stringByAppendingString:[provinceRegion objectForKey:@"local_name"]];
        }
        if(cityRegion != nil){
            region = [region stringByAppendingString:[cityRegion objectForKey:@"local_name"]];
        }
        if(countyRegion != nil){
            region = [region stringByAppendingString:[countyRegion objectForKey:@"local_name"]];
        }
        _labLive.text = region;
        [self hidePickersLive];
    }
    else if([identification isEqual:@"sex"]){
        NSString *sexStr = [sexArray objectAtIndex:[pickerView selectedRowInComponent:0]];
        if ([sexStr isEqual:@"男"]){
            getSex = 1;
            self.labSex.text = @"男";
        }
        else
        {
            getSex = 2;
            self.labSex.text = @"女";
        }
        [self hidePickers];
    }
}



/*
 * 选择区域完成
 */
- (IBAction)selectRegionOKDate:(id)sender {
    birthday = datePickerView.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.labDate.text = [formatter stringFromDate:birthday];
    [self hidePickerDate];
}

-(void)hidePickers{
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 0;
        pickerSelectView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 240);
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [pickerSelectView removeFromSuperview];
        
    }];
}

-(void)hidePickersLive{
    [UIView animateWithDuration:0.3 animations:^{
        liveMaskView.alpha = 0;
        livePickerSelectView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 240);
    } completion:^(BOOL finished) {
        [liveMaskView removeFromSuperview];
        [livePickerSelectView removeFromSuperview];
        
    }];
}

-(void)hidePickerDate{
    [UIView animateWithDuration:0.3 animations:^{
        dateMaskView.alpha = 0;
        datePickerSelectView.frame = CGRectMake(0, kScreenHeight, kScreenWidth, 240);
    } completion:^(BOOL finished) {
        [dateMaskView removeFromSuperview];
        [datePickerSelectView removeFromSuperview];
        
    }];
}

-(void)sexClick{
    
    [self hidenKeyboard];
    identification = @"sex";
    maskView.alpha = 0;
    [self.view addSubview:maskView];
    [self.view addSubview:pickerSelectView];
    
    [UIView animateWithDuration:0.3 animations:^{
        maskView.alpha = 0.3;
        pickerSelectView.frame = CGRectMake(0, kScreenHeight - 240, kScreenWidth, 240);
    }];
}

-(void)dateClick{
    [self hidenKeyboard];
    dateMaskView.alpha = 0;
    [self.view addSubview:dateMaskView];
    [self.view addSubview:datePickerSelectView];
    
    [UIView animateWithDuration:0.3 animations:^{
        dateMaskView.alpha = 0.3;
        datePickerSelectView.frame = CGRectMake(0, kScreenHeight - 240, kScreenWidth, 240);
    }];
}

-(void)liveClick{
    [self hidenKeyboard];
    identification = @"live";
    liveMaskView.alpha = 0;
    [self.view addSubview:liveMaskView];
    [self.view addSubview:livePickerSelectView];
    
    [UIView animateWithDuration:0.3 animations:^{
        liveMaskView.alpha = 0.3;
        livePickerSelectView.frame = CGRectMake(0, kScreenHeight - 240, kScreenWidth, 240);
    }];
}

-(void) loadWebData{
    
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/member!info.do"]];
                       
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
                           
                           [self setViewValue:data];
                           
                       });
                   });
    
}

//填写控件默认值
-(void)setViewValue:(NSDictionary *) dict{
    
    NSString *getPCR = @"";;
    NSString *getWebProvince = [dict objectForKey:@"province"];
    
    if ([getWebProvince isKindOfClass:[NSString class]] && getWebProvince.length > 0){
        getPCR = [getPCR stringByAppendingString:getWebProvince];
        provinceRegion = @{@"region_id":[dict objectForKey:@"province_id"], @"local_name":[dict objectForKey:@"province"]};
    }
    
    NSString *getWebCity = [dict objectForKey:@"city"];
    if ([getWebCity isKindOfClass:[NSString class]]){
        getPCR = [getPCR stringByAppendingString:getWebCity];
        cityRegion = @{@"region_id":[dict objectForKey:@"city_id"], @"local_name":[dict objectForKey:@"city"]};
    }
    
    NSString *getWebRegion = [dict objectForKey:@"region"];
    if ([getWebRegion isKindOfClass:[NSString class]]){
        getPCR = [getPCR stringByAppendingString:getWebRegion];
        countyRegion = @{@"region_id":[dict objectForKey:@"region_id"], @"local_name":[dict objectForKey:@"region"]};
    }
    
    if (getPCR.length >0){
        self.labLive.text = getPCR;
    }
    
    NSString *getZip = [dict objectForKey:@"zip"];
    if ([getZip isKindOfClass:[NSString class]]){
        self.txtPost.text = getZip;
    }
    
    NSNumber *numberBrithday =[dict objectForKey:@"birthday"];
    if ([numberBrithday isKindOfClass:[NSNumber class]]){
        
        birthday = [NSDate dateWithTimeIntervalSince1970:[numberBrithday longValue]];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
        [formatter setDateFormat:@"YYYY-MM-dd"];
        NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
        [formatter setTimeZone:timeZone];
        
        NSString *birthdayStr = [formatter stringFromDate:birthday];
        self.labDate.text = birthdayStr;
    }
    
    
    NSNumber *getWebSex = [dict objectForKey:@"sex"];
    if ([getWebSex intValue] == -1 || [getWebSex intValue] == 1){
        getSex =1;
        self.labSex.text =@"男";
    }
    else{
        getSex = 0;
        self.labSex.text = @"女";
    }
    
    NSString *getAddress = [dict objectForKey:@"address"];
    if([getAddress isKindOfClass:[NSString class]]){
        self.txtAddress.text = getAddress;
    }
    
    NSString *getTel = [dict objectForKey:@"tel"];
    if ([getTel isKindOfClass:[NSString class]]){
        self.txtTel.text = getTel;
    }
    
    NSString *getMobile = [dict objectForKey:@"mobile"];
    if ([getMobile isKindOfClass:[NSString class]]){
        self.txtMobile.text = getMobile;
    }
    
    NSString *getName = [dict objectForKey:@"name"];
    if ([getName isKindOfClass:[NSString class]]){
        self.txtName.text = getName;
    }
    
    
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
                           
                           [livePickerView reloadComponent:_type];
                           if(_type == 0){
                               if(provinceArray.count > 0){
                                   NSDictionary *provice = [provinceArray objectAtIndex:0];
                                   [self loadData:[[provice objectForKey:@"region_id"] intValue] type:1];
                               }else{
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

#pragma mark -代理的实现

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerViews
{
    if ([identification isEqual:@"sex"]){
        return 1;
    }
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerViews numberOfRowsInComponent:(NSInteger)component
{
    if ([identification isEqual:@"sex"]){
        return 2;
    }
    else
    {
        if (component == 0) {
            return provinceArray.count;
        } else if (component == 1) {
            return cityArray.count;
        } else {
            return countyArray.count;
        }
    }
    return 0;
    
}

-(NSString *)pickerView:(UIPickerView *)pickerViews titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([identification isEqual:@"sex"]){
        return [sexArray objectAtIndex:row];
    }
    else
    {
        if (component == 0) {
            NSDictionary *province = [provinceArray objectAtIndex:row];
            return [province objectForKey:@"local_name"];
        } else if (component == 1) {
            NSDictionary *city = [cityArray objectAtIndex:row];
            return [city objectForKey:@"local_name"];
        } else {
            NSDictionary *county = [countyArray objectAtIndex:row];
            return [county objectForKey:@"local_name"];
        }
        
    }
    
}



- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return kScreenWidth / 3;
}

- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    if ([identification isEqual:@"live"])
    {
        if (component == 0) {
            
            NSDictionary *province = [provinceArray objectAtIndex:row];
            [self loadData:[[province objectForKey:@"region_id"] intValue] type:1];
            [_pickerView selectedRowInComponent:1];
            [_pickerView selectedRowInComponent:2];
            return;
        }
        if (component == 1) {
            NSDictionary *city = [cityArray objectAtIndex:row];
            [self loadData:[[city objectForKey:@"region_id"] intValue] type:2];
            return;
        }
        
    }
    
    
}

- (UIView *)pickerView:(UIPickerView *)pickerViews viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    if ([identification isEqual:@"live"])
    {
        UILabel *myView = nil;
        myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)];
        myView.textAlignment = NSTextAlignmentCenter;
        myView.font = [UIFont systemFontOfSize:14];
        myView.backgroundColor = [UIColor clearColor];
        if (component == 0) {
            NSDictionary *province = [provinceArray objectAtIndex:row];
            myView.text = [province objectForKey:@"local_name"];
        } else if (component == 1) {
            NSDictionary *city = [cityArray objectAtIndex:row];
            myView.text = [city objectForKey:@"local_name"];
        } else {
            NSDictionary *county = [countyArray objectAtIndex:row];
            myView.text = [county objectForKey:@"local_name"];
        }
        return myView;
        
    }
    
    UILabel *myView = nil;
    myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 100, 30)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = [UIFont systemFontOfSize:14];
    myView.backgroundColor = [UIColor clearColor];
    
    myView.text = [sexArray objectAtIndex:row];
    
    return myView;
    
    
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
