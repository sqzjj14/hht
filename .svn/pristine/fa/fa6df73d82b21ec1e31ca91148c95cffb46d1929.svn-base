//
//  MobileRegisterViewController2.m
//  JavaMall
//
//  Created by Dawei on 12/24/15.
//  Copyright © 2015 Enation. All rights reserved.
//

#import "FindPassViewController2.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "StringHelper.h"
#import "FindPassViewController3.h"

@interface FindPassViewController2 ()

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *mobileCode;
- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *resendBtn;
- (IBAction)resend:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation FindPassViewController2
@synthesize nextBtn, headerView, mobileCode, resendBtn;
@synthesize messageLabel;
@synthesize mobile;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    UIImage *normalBg = [UIImage imageNamed:@"Button_A.png"];
    CGFloat top = 25; // 顶端盖高度
    CGFloat bottom = 25 ; // 底端盖高度
    CGFloat left = 10; // 左端盖宽度
    CGFloat right = 10; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    // 指定为拉伸模式，伸缩后重新赋值
    normalBg = [normalBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    UIImage *disableBg = [UIImage imageNamed:@"Button_B.png"];
    disableBg = [disableBg resizableImageWithCapInsets:insets resizingMode:UIImageResizingModeStretch];
    
    [nextBtn setBackgroundImage:normalBg forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [resendBtn setBackgroundImage:normalBg forState:UIControlStateNormal];
    [resendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [resendBtn setBackgroundImage:disableBg forState:UIControlStateDisabled];
    [resendBtn setTitleColor:[UIColor colorWithHexString:@"#868686"] forState:UIControlStateDisabled];
    
    mobileCode.delegate = self;
    messageLabel.text = [NSString stringWithFormat:@"短信已发送至%@", mobile];
    
    //注册键盘响应事件方法
    [mobileCode addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    
    //添加手势，点击屏幕其他区域关闭键盘的操作
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidenKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
    
    [self startTimer];
    
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
    if (sender == self.mobileCode){
        [self hidenKeyboard];
        [self next:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.mobileCode resignFirstResponder];
}

//下一步
- (IBAction)next:(id)sender {
    if(mobileCode.text.length == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入验证码！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    [SVProgressHUD showWithStatus:@"正在加载..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!validMobile.do?mobile=%@&mobilecode=%@",
                                                        mobile, mobileCode.text]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"验证码检验失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           FindPassViewController3 *findPassViewController3 = (FindPassViewController3 *)[super controllerFromMainStroryBoard:@"FindPass3"];
                           findPassViewController3.mobile = mobile;
                           findPassViewController3.mobileCode = mobileCode.text;
                           [[self navigationController] pushViewController:findPassViewController3 animated:YES];
                       });
                   });
}

//启动按钮倒计时
- (void) startTimer{
    resendBtn.enabled = NO;
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [resendBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                resendBtn.enabled = YES;
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                resendBtn.titleLabel.text = [NSString stringWithFormat:@"%d秒后重新发送",timeout];
                [resendBtn setTitle:[NSString stringWithFormat:@"%d秒后重新发送",timeout] forState:UIControlStateDisabled];
            });
            timeout--;
        }
        
    });
    dispatch_resume(_timer);
}

//后退
- (IBAction)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

//重新发送验证码
- (IBAction)resend:(id)sender {
    if(mobile.length == 0 || ![StringHelper validateMobile:mobile]){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"正在发送验证码..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!sendRegisterCode.do&?mobile=%@",
                                                        mobile]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"发送验证码失败,请您重试！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           [self startTimer];
                       });
                   });
}
@end
