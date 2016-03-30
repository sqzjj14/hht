//
//  MobileRegisterViewController3.m
//  JavaMall
//
//  Created by Dawei on 12/24/15.
//  Copyright © 2015 Enation. All rights reserved.
//

#import "FindPassViewController3.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "StringHelper.h"

@interface FindPassViewController3 ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *finishBtn;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
- (IBAction)mobileRegister:(id)sender;
- (IBAction)back:(id)sender;
@end

@implementation FindPassViewController3

@synthesize finishBtn, headerView, passwordField;
@synthesize mobile, mobileCode;

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
    [finishBtn setBackgroundImage:registerBg forState:UIControlStateNormal];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    passwordField.delegate = self;
    
    //注册键盘响应事件方法
    [passwordField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == self.passwordField){
        [self hidenKeyboard];
        [self mobileRegister:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.passwordField resignFirstResponder];
}

//注册
- (IBAction) mobileRegister:(id)sender {
    if(passwordField.text.length < 6 || passwordField.text.length > 12){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"密码长度为6到12位！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在修改密码..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!mobileChangePassword.do?mobile=%@&mobilecode=%@&password=%@",
                                                        mobile, mobileCode, passwordField.text]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"修改密码成功,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
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
                           [defaults setObject: mobile forKey: @"username"];
                           [defaults synchronize];
                           
                           [SVProgressHUD setErrorImage:nil];
                           [SVProgressHUD showErrorWithStatus:@"修改密码成功,请您重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });
}

//后退
- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

@end
