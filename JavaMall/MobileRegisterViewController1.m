
#import "MobileRegisterViewController1.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"
#import "HttpClient.h"
#import "StringHelper.h"
#import "MobileRegisterViewController2.h"

@interface MobileRegisterViewController1 ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UITextField *mobile;
- (IBAction)next:(id)sender;
- (IBAction)back:(id)sender;

@end

@implementation MobileRegisterViewController1

@synthesize nextBtn, headerView, mobile;

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
    [nextBtn setBackgroundImage:registerBg forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    mobile.delegate = self;

    //注册键盘响应事件方法
    [mobile addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];

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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    if (sender == self.mobile){
        [self hidenKeyboard];
        [self next:nil];
    }
}

//隐藏键盘的方法
-(void)hidenKeyboard{
    [self.mobile resignFirstResponder];
}


- (IBAction)next:(id)sender {
    if(mobile.text.length == 0 || ![StringHelper validateMobile:mobile.text]){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }

    [SVProgressHUD showWithStatus:@"正在发送验证码..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                HttpClient *client = [[HttpClient alloc] init];
                NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/member!sendRegisterCode.do?mobile=%@",
                                mobile.text]];
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
                    MobileRegisterViewController2 *mobileRegisterViewController2 = (MobileRegisterViewController2 *)[super controllerFromMainStroryBoard:@"MobileRegister2"];
                    mobileRegisterViewController2.mobile = mobile.text;
                    [[self navigationController] pushViewController:mobileRegisterViewController2 animated:YES];
                });
            });
}

//后退
- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end