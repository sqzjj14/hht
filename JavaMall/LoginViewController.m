//
//  LoginViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "LoginViewController.h"
#import "UIColor+HexString.h"
#import "RegisterViewController.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "MobileRegisterViewController1.h"
#import "FindPassViewController1.h"
#import "AppDelegate.h"
#import "ImagePlayerView.h"
#import "Constants.h"

@interface LoginViewController ()<ImagePlayerViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *usernameView;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *findpassBtn;
- (IBAction)login:(id)sender;
- (IBAction)register:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)findpass:(id)sender;
//imagePlayView;
@property (weak, nonatomic) IBOutlet ImagePlayerView *playView;
@property (nonatomic,strong) NSArray *imageArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headConstrains;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *LoginHeadconstraints;
//记录原约束的数值
@property (nonatomic,assign)CGFloat ConstraintsRemark;

@end

@implementation LoginViewController

@synthesize usernameView, username, password, loginBtn, registerBtn, headerView;
@synthesize findpassBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    UIImage *loginBg = [UIImage imageNamed:@"Button_A.png"];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    loginBg = [loginBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    [loginBtn setBackgroundImage:loginBg forState:UIControlStateNormal];
    [loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    findpassBtn.hidden = !MOBILE_VALIDATION;
    
    username.delegate = self;
    password.delegate = self;
    //注册键盘响应事件方法
    [username addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [password addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    //创建滚动视图
    [self initPlayView];
    
}
- (void)initPlayView{
    self.playView.imagePlayerViewDelegate = (id)self;
    self.imageArr = @[[UIImage imageNamed:@"loginAD_1"],
                      [UIImage imageNamed:@"loginAD_2"],
                      [UIImage imageNamed:@"loginAD_3"]];
    // set auto scroll interval to x seconds
    self.playView.scrollInterval = 3.0f;
    
    // adjust pageControl position
    self.playView
    .pageControlPosition = ICPageControlPosition_BottomCenter;
    
    // hide pageControl or not
    self.playView.hidePageControl = NO;
    
    
    // adjust edgeInset
    //    self.imagePlayerView.edgeInsets = UIEdgeInsetsMake(10, 20, 30, 40);
    
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
    [super setBorderWithView:usernameView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark textfield delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    //ConstraintsRemark = _LoginHeadconstraints.constant;
    
    CGRect frame = [textField convertRect:textField.frame toView:self.view];
    int i = 32;
    int offset = frame.origin.y + i + frame.size.height - (self.view.frame.size.height - 216.0);
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    if (offset > 0) {
       // self.view.frame = CGRectMake(0, -offset, self.view.frame.size.width,self.view.frame.size.height);
        _headConstrains.constant = -offset;
        [UIView commitAnimations];
    }
}
//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == username) {
        [self.password becomeFirstResponder];
    }else if (sender == self.password){
        [self hidenKeyboard];
        [self login:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.username resignFirstResponder];
    [self.password resignFirstResponder];
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:animationDuration];
    _headConstrains.constant = 0 ;
    [UIView commitAnimations];
}

- (IBAction)login:(id)sender {
    if(username.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"用户名不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    if(password.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"密码不能为空！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"登录中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!login.do?username=%@&password=%@", username.text, password.text]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"登录失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"用户名或密码错误！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           //登录成功
                           NSDictionary *data = [result objectForKey:@"data"];
                           
                           //保存数据
                           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                           [defaults setObject: [data objectForKey:@"username"] forKey: @"username"];
                           [defaults setObject: [data objectForKey:@"face"] forKey: @"face"];
                           [defaults setObject: [data objectForKey:@"level"] forKey: @"level"];
                           [defaults synchronize];
                           
                           [[NSNotificationCenter defaultCenter] postNotificationName:nLogin object:nil];
                           
                           [SVProgressHUD setErrorImage:nil];
                           [SVProgressHUD showErrorWithStatus:@"登录成功！" maskType:SVProgressHUDMaskTypeBlack];
                           
                           
                          
                           
                           
                           
                          UIApplication *app = [UIApplication sharedApplication];
                           AppDelegate *appdelegate =  (AppDelegate*)app.delegate;
                          if( appdelegate.window.rootViewController == self)
                          {
                              [appdelegate.window setRootViewController:[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"Main"]];
                              
                              [self presentViewController:[super controllerFromMainStroryBoard:@"Main"] animated:YES completion:nil];
                          }
                          else{
                               [self dismissViewControllerAnimated:YES completion:nil];
//                              [self presentViewController:[super controllerFromMainStroryBoard:@"Main"] animated:YES completion:nil];
                          }
                       });
                   });
    
}


- (IBAction)register:(id)sender {
    if(MOBILE_VALIDATION){
        MobileRegisterViewController1 *vc = (MobileRegisterViewController1 *)[super controllerFromMainStroryBoard:@"MobileRegister1"];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [self presentViewController:[super controllerFromMainStroryBoard:@"Register"] animated:NO completion:nil];
    }
}

//后退
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//找回密码
- (IBAction)findpass:(id)sender {
    FindPassViewController1 *vc = (FindPassViewController1 *)[super controllerFromMainStroryBoard:@"FindPass1"];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];

}
@end
