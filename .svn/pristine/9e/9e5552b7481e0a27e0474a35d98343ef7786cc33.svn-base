//
//  PasswordViewController.m
//  JavaMall
//
//  Created by Dawei on 7/9/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "PasswordViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"

@interface PasswordViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *oldpassView;
@property (weak, nonatomic) IBOutlet UIView *newpassView;
@property (weak, nonatomic) IBOutlet UITextField *oldpassTextField;
@property (weak, nonatomic) IBOutlet UITextField *newpassTextField;
@property (weak, nonatomic) IBOutlet UITextField *repassTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeBtn;

- (IBAction)back:(id)sender;
- (IBAction)changepass:(id)sender;
@end

@implementation PasswordViewController

@synthesize headerView,oldpassView,newpassView;
@synthesize oldpassTextField, newpassTextField,repassTextField,changeBtn;

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
    [changeBtn setBackgroundImage:registerBg forState:UIControlStateNormal];
    [changeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    oldpassTextField.delegate = self;
    newpassTextField.delegate = self;
    repassTextField.delegate = self;
    
    //注册键盘响应事件方法
    [oldpassTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [newpassTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [repassTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
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
    [super setBorderWithView:oldpassView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:newpassView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == oldpassTextField) {
        [self.newpassTextField becomeFirstResponder];
    }else if (sender == newpassTextField) {
        [self.repassTextField becomeFirstResponder];
    }else if (sender == self.repassTextField){
        [self hidenKeyboard];
        [self changepass:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.oldpassTextField resignFirstResponder];
    [self.newpassTextField resignFirstResponder];
    [self.repassTextField resignFirstResponder];
}

- (IBAction)changepass:(id)sender {
    if(oldpassTextField.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"旧密码不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(newpassTextField.text.length < 6 || newpassTextField.text.length > 20){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"新密码的长度为6-20个字符！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if([repassTextField.text isEqualToString:newpassTextField.text] == NO){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"新密码和确认密码输入的不一致！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在修改密码..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!changePassword.do?oldpassword=%@&password=%@&re_passwd=%@", oldpassTextField.text, newpassTextField.text, repassTextField.text]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"修改密码失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
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
                           [defaults removeObjectForKey:@"username"];
                           [defaults removeObjectForKey:@"face"];
                           [defaults removeObjectForKey:@"level"];
                           [defaults synchronize];
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:nChangePassword object:nil];
                           [SVProgressHUD setSuccessImage:nil];
                           [SVProgressHUD showSuccessWithStatus:@"修改密码成功,请您重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                           [self dismissViewControllerAnimated:YES completion:nil];
                       });
                   });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
