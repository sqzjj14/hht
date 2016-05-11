//
//  RegisterViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "ImagePlayerView.h"
#import "HttpClient.h"
#import "Masonry.h"
#import "UIImageView+WebCache.h"
#import "UserView.h"

#import "CouponCell.h"


@interface RegisterViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repassword;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;

- (IBAction)registerUser:(id)sender;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *registView;

//需要部分－滚动视图 与 验证码
@property (weak, nonatomic) IBOutlet ImagePlayerView *playView;
@property (nonatomic,strong) NSArray *imageArr;

@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
- (IBAction)sendMessage:(id)sender;
//重发计数
@property (nonatomic,assign)NSInteger count;
//验证码
@property (nonatomic,assign)NSInteger identifyingCode;
@property (weak, nonatomic) IBOutlet UITextField *identifyingCodeTF;
//计时器
@property (nonatomic,strong)NSTimer *time;
//优惠劵数据源
@property (nonatomic,strong)NSMutableArray *dataSource;
//关闭优惠劵手势
@property (nonatomic,strong)UITapGestureRecognizer *coupontap;
@property (nonatomic,strong)UIView *couponView;
//关闭用户协议手势
@property (nonatomic,strong)UITapGestureRecognizer *usertap;
@property (nonatomic,strong)UserView *userView;
//商户号
@property (weak, nonatomic) IBOutlet UITextField *business;
@end

@implementation RegisterViewController{
    HttpClient *client;
}

@synthesize headerView, usernameView, passwordView, username, password, repassword, registerBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    UIImage *registerBg = [UIImage imageNamed:@"Button_A.png"];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    registerBg = [registerBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [registerBtn setBackgroundImage:registerBg forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    username.delegate = self;
    password.delegate = self;
    repassword.delegate = self;
    _identifyingCodeTF.delegate = self;
    
    
    //注册键盘响应事件方法
    [username addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [password addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [repassword addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
     [_identifyingCodeTF addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
     [_business addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    //创建滚动视图
    [self initPlayView];
    //创建计时器
    _count = 0;
    _time = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startTime) userInfo:nil repeats:YES];
    
    client = [[HttpClient alloc]init];
    _dataSource = [[NSMutableArray alloc]init];
    
    // test
    //[self initCouponView];
    NSLog(@"x=%f",_userView.userScrollView.contentOffset.x);
    NSLog(@"y=%f",_userView.userScrollView.contentOffset.y);

}


- (void)initPlayView{
    self.playView.imagePlayerViewDelegate = (id)self;
    self.imageArr = @[[UIImage imageNamed:@"loginAD_1"],
                      [UIImage imageNamed:@"loginAD_2"],
                      [UIImage imageNamed:@"loginAD_3"]];
    self.playView.scrollInterval = 3.0f;
    
    self.playView
    .pageControlPosition = ICPageControlPosition_BottomCenter;
    
    self.playView.hidePageControl = NO;
    
    
    [self.playView reloadData];
    
}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return self.imageArr.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index
{
    // recommend to use SDWebImage lib to load web image
    //    [imageView setImageWithURL:[self.imageURLs objectAtIndex:index] placeholderImage:nil];
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        imageView.image = self.imageArr[index];
//    });
    imageView.image = self.imageArr[index];
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index
{
    NSLog(@"did tap index = %d", (int)index);
    [self hidenKeyboard];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    //[super setBorderWithView:usernameView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
   // [super setBorderWithView:passwordView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    CGRect frame = [textField convertRect:textField.frame toView:self.view];
//    int i = 15;
//    int offset = frame.origin.y + i + frame.size.height - (self.view.frame.size.height - 250.0);
//    NSTimeInterval animationDuration = 0.30f;
//    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
//    [UIView setAnimationDuration:animationDuration];
//    
//    if (offset > 0) {
//        //_registView.frame = CGRectMake(0, -offset, self.view.frame.size.width,self.view.frame.size.height
//        [UIView commitAnimations];
//    }
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    [self hidenKeyboard];
    
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self.repassword resignFirstResponder];
    [self.identifyingCodeTF resignFirstResponder];
    [self.business resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    [UIView commitAnimations];
}
#pragma mark 键盘的方法就是以上了～
#pragma mark 创建用户协议视图
- (IBAction)creatUserView:(UIButton *)sender {
    [self hidenKeyboard];
    _userView = [[NSBundle mainBundle]loadNibNamed:@"UserView" owner:nil options:nil][0];
    _userView.backgroundColor = [UIColor whiteColor];
    _userView.layer.shadowOffset = CGSizeMake(1, 1);
    _userView.layer.shadowColor = [[UIColor colorWithHexString:@"#24A676"]CGColor];
    _userView.layer.shadowOpacity = 0.5;
    _userView.layer.cornerRadius = 2 ;
    _userView.layer.shadowRadius=5;
    [self.view addSubview:_userView];
    [_userView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
        make.top.equalTo(self.view.mas_top).with.offset(70);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-100);
        
    }];
    //yesBtn
 //   _userView.yesBtn.layer.shadowOffset = CGSizeMake(1, 1);
//    _userView.yesBtn.layer.shadowColor = [UIColor redColor].CGColor;
//    _userView.yesBtn.layer.shadowOpacity = 0.5;
//    _userView.yesBtn.layer.cornerRadius = 2 ;
//    _userView.yesBtn.layer.shadowRadius=5;
    //tap
    _usertap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelUser:)];
    _usertap.numberOfTapsRequired = 1;
    [_userView addGestureRecognizer:_usertap];
    
}
-(void)cencelUser:(UITapGestureRecognizer*)tap{
    [_userView removeFromSuperview];
    [self.view removeGestureRecognizer:tap];
}
#pragma mark 注册的判断
- (IBAction)registerUser:(id)sender {
    [self hidenKeyboard];
    NSString *Code = [NSString stringWithFormat:@"%d",_identifyingCode];
    NSLog(@"%@",_identifyingCodeTF.text);
    if(![_identifyingCodeTF.text isEqualToString: Code]){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"验证码错误" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(username.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用户名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
//    if(username.text.length < 4 || username.text.length > 20){
//        [SVProgressHUD setErrorImage:nil];
//        [SVProgressHUD showErrorWithStatus:@"用户名的长度为4-20个字符！" maskType:SVProgressHUDMaskTypeBlack];
//        return;
  //  }
    if(_business.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用商户名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if (![self isMobileNumber:username.text]) {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if([username.text rangeOfString:@"@"].location != NSNotFound){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用户名中不能包含@等特殊字符！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }

    if(password.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"密码不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    if([password.text isEqualToString:repassword.text] == NO){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"两次输入密码不一致！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(password.text.length <= 5){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请设置大于6位的密码" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在注册..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!register.do?username=%@&password=%@&merchant_name=%@", username.text, password.text,_business.text]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"注册失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           //注册成功,保存数据
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           [defaults setObject: username.text forKey: @"username"];
                           [defaults synchronize];
                           
                           [SVProgressHUD setErrorImage:nil];
                           [SVProgressHUD showErrorWithStatus:@"注册成功！" maskType:SVProgressHUDMaskTypeBlack];
                           [self initCouponView];
                          // [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10 * 中国移动：China Mobile
     11 * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12 */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15 * 中国联通：China Unicom
     16 * 130,131,132,152,155,156,185,186
     17 */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20 * 中国电信：China Telecom
     21 * 133,1349,153,180,189
     22 */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25 * 大陆地区固话及小灵通
     26 * 区号：010,020,021,022,023,024,025,027,028,029
     27 * 号码：七位或八位
     28 */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
#pragma mark 验证码发送
- (IBAction)sendMessage:(id)sender {
    if (![self isMobileNumber:username.text]) {
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"手机号码格式错误" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    else{
        
        [SVProgressHUD showWithStatus:@"正在发送..." maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            HttpClient *httpHelper = [[HttpClient alloc]init];
            //4位数字验证码
            _identifyingCode = (arc4random()%1000)+9000;
            //post参数字典
            NSMutableDictionary *pramaDIC = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
            @"send",@"action",
            @"4905",@"userid",
            @"润植科技",@"account",
            @"rzhkj012",@"password",
            username.text,@"mobile",
            [NSString stringWithFormat:@"您的验证码为：%ld,请及时完成注册,如非本人操作请忽略。【花卉通】",(long)_identifyingCode],@"content",
            @"",@"sendTime",
            @"",@"extno",nil];
            
            NSString *XMLstring = [httpHelper post:@"http://211.147.242.161:8888/sms.aspx" useEncoding:NSUTF8StringEncoding withData:pramaDIC];
        _count = 60;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD setErrorImage:nil];
            });
         
    //----------处理返回的XML字段------------
            if (XMLstring.length == 0 || [XMLstring rangeOfString:@"Fail"].location != NSNotFound) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更UI
                    [SVProgressHUD setErrorImage:nil];
                    [SVProgressHUD showErrorWithStatus:@"发送错误，请再次尝试" maskType:SVProgressHUDMaskTypeBlack];
                });
                
        _count = 0;
                return ;
            }
            else if ([XMLstring rangeOfString:@"Success"].location != NSNotFound){
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 更UI
                    [SVProgressHUD setErrorImage:nil];
                    [SVProgressHUD showErrorWithStatus:@"发送成功" maskType:SVProgressHUDMaskTypeBlack];
                });
                return;
            }
            
        });
    }
    
}
-(void)startTime{
    if (_count == 0){
        [_messageBtn setTitle:@"获取短信验证" forState:UIControlStateNormal];
        [_messageBtn setTintColor:[UIColor colorWithHexString:@"#00bfff"]];
        [_messageBtn setEnabled:YES];
    }
    else if (_count <= 60 && _count > 0){
        _count --;
        [_messageBtn setTitle:[NSString stringWithFormat:@"%d",_count] forState:UIControlStateNormal];
        [_messageBtn setTintColor:[UIColor colorWithHexString:@"#00bfff"]];
        [_messageBtn setEnabled:NO];
    }
    
}
#pragma mark 注册送优惠卷视图
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
        }
    }
}
-(void)initCouponView{
    [self getHttp];
    NSInteger couponCount = [_dataSource count];
    
    //contentView
    //UIView *CouponView = [[UIView alloc]initWithFrame:CGRectMake(0, 300, 320, 80 * 2)];
    _couponView = [[UIView alloc]init];
    _couponView.backgroundColor = [UIColor whiteColor];
    _couponView.layer.shadowOffset = CGSizeMake(1, 1);
    _couponView.layer.shadowColor = [[UIColor colorWithHexString:@"#24A676"]CGColor];
    _couponView.layer.shadowOpacity = 0.5;
    _couponView.layer.cornerRadius = 2 ;
    _couponView.layer.shadowRadius=5;
    [self.view addSubview:_couponView];
    [_couponView mas_makeConstraints:^(MASConstraintMaker *make) {
        //make.centerX.equalTo(self.view.mas_centerX).with.offset(0);
        make.top.equalTo(self.view.mas_top).with.offset(70);
        make.left.equalTo(self.view.mas_left).with.offset(40);
        make.right.equalTo(self.view.mas_right).with.offset(-40);
        make.bottom.equalTo(self.view.mas_bottom).with.offset(-100);
        
    }];
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.backgroundColor = [UIColor redColor];
    [_couponView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_couponView.mas_top);
        make.leading.equalTo(_couponView.mas_leading);
        make.trailing.equalTo(_couponView.mas_trailing);
        make.bottom.equalTo(_couponView.mas_bottom);
        make.width.equalTo(_couponView.mas_width);
        make.height.equalTo(_couponView.mas_height);
    }];
    imageView.image = [UIImage imageNamed:@"couponAD.jpg"];
    
    //tap
    _coupontap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cencelImage:)];
    _coupontap.numberOfTapsRequired = 1;
    [_couponView addGestureRecognizer:_coupontap];
    
    
    //cell
    for (int i = 0; i <couponCount; i++) {
        CouponCell *cell = [[NSBundle mainBundle]loadNibNamed:@"CouponCell" owner:nil options:nil][0];
        NSMutableDictionary *couponModel = _dataSource[i];
        cell.name.text = [couponModel objectForKey:@"name"];
        cell.remark.text = [couponModel objectForKey:@"remark"];
        cell.time.text = [couponModel objectForKey:@"time"];
        [cell.image sd_setImageWithURL:[NSURL URLWithString:[couponModel objectForKey:@"imageUrl"]]];
        cell.backgroundColor = [UIColor whiteColor];
        cell.frame = CGRectMake(0, 80 * i, 320, 80 );
       // [CouponView addSubview:cell];
    }
}
-(void)cencelImage:(UITapGestureRecognizer*)tap{
    [_couponView removeFromSuperview];
    [self.view removeGestureRecognizer:tap];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
