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

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *repassword;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
- (IBAction)registerUser:(id)sender;
- (IBAction)back:(id)sender;

@end

@implementation RegisterViewController

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
    
    //注册键盘响应事件方法
    [username addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [password addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [repassword addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];

}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:usernameView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:passwordView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == username) {
        [self.password becomeFirstResponder];
    }else if (sender == password) {
        [self.repassword becomeFirstResponder];
    }else if (sender == self.password){
        [self hidenKeyboard];
        [self registerUser:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    [self.repassword resignFirstResponder];
}


- (IBAction)registerUser:(id)sender {
    if(username.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用户名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(username.text.length < 4 || username.text.length > 20){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用户名的长度为4-20个字符！" maskType:SVProgressHUDMaskTypeBlack];
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
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!register.do?username=%@&password=%@", username.text, password.text]];
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
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });
}
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
