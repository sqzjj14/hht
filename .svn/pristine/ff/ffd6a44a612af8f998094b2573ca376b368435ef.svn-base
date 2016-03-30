//
//  ReceiptViewController.m
//  JavaMall
//
//  Created by Dawei on 7/2/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "ReceiptViewController.h"
#import "UIColor+HexString.h"
#import "SVProgressHUD.h"

@interface ReceiptViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIButton *notBtn;
@property (weak, nonatomic) IBOutlet UIButton *personBtn;
@property (weak, nonatomic) IBOutlet UIButton *companyBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *titleView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
- (IBAction)back:(id)sender;

@end

@implementation ReceiptViewController

@synthesize headerView, notBtn, personBtn, companyBtn, scrollView, titleTextField;
@synthesize receiptType, receiptTitle, receiptContent;
@synthesize titleView, contentView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    scrollView.backgroundColor = [UIColor colorWithHexString:@"#f3f4f6"];

    if(receiptContent == nil){
        receiptContent = @"办公用品";
    }
    titleTextField.text = receiptTitle;
    
    //注册键盘响应事件方法
    [titleTextField addTarget:self action:@selector(returnOnKeyboard:) forControlEvents:UIControlEventEditingDidEndOnExit];
    UITapGestureRecognizer *specTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchOther:)];
    [specTapGesture setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:specTapGesture];

    
    [self initView];
    
    //确定
    UIView *okView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 44, kScreenWidth, 44)];
    
    UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 250) / 2, 5, 250, 34)];
    [okButton setBackgroundColor:[UIColor colorWithHexString:@"#f15352"]];
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    [okButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:14]];
    [okButton addTarget:self action:@selector(OK:) forControlEvents:UIControlEventTouchUpInside];
    [okView addSubview:okButton];
    
    [self.view addSubview:okView];
}

- (void) initView{
    if(receiptType == nil || [receiptType isEqualToString:@""]){
        notBtn.layer.borderColor = [UIColor redColor].CGColor;
        titleView.hidden = YES;
        contentView.hidden = YES;
    }else{
        notBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    }
    notBtn.layer.borderWidth = 1.0;
    notBtn.layer.masksToBounds = YES;
    notBtn.tag = 0;
    notBtn.layer.cornerRadius = 3.0;
    [notBtn addTarget:self action:@selector(clickType:) forControlEvents:UIControlEventTouchUpInside];
    
    if([receiptType isEqualToString:@"个人"]){
        personBtn.layer.borderColor = [UIColor redColor].CGColor;
    }else{
        personBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    }
    personBtn.layer.borderWidth = 1.0;
    personBtn.layer.masksToBounds = YES;
    personBtn.tag = 1;
    personBtn.layer.cornerRadius = 3.0;
    [personBtn addTarget:self action:@selector(clickType:) forControlEvents:UIControlEventTouchUpInside];
    
    if([receiptType isEqualToString:@"单位"]){
        companyBtn.layer.borderColor = [UIColor redColor].CGColor;
    }else{
        companyBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    }
    companyBtn.layer.borderWidth = 1.0;
    companyBtn.layer.masksToBounds = YES;
    companyBtn.tag = 2;
    companyBtn.layer.cornerRadius = 3.0;
    [companyBtn addTarget:self action:@selector(clickType:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *subviews = contentView.subviews;
    for (UIView *v in subviews) {
        if([v isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)v;
            [btn setImage:[UIImage imageNamed:@"cart_round_check1.png"] forState:UIControlStateNormal];
            [btn setImage:[UIImage imageNamed:@"cart_round_check2.png"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(selectContent:) forControlEvents:UIControlEventTouchUpInside];
            if([btn.titleLabel.text isEqualToString:receiptContent]){
                [btn setSelected:YES];
            }else{
                [btn setSelected:NO];
            }
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)clickType:(id)sender{
    [self hideKeyboard];
    UIButton *button = (UIButton *)sender;
    notBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    personBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    companyBtn.layer.borderColor = [UIColor colorWithHexString:@"#cdcdcd"].CGColor;
    
    button.layer.borderColor = [UIColor redColor].CGColor;
    
    if(button == notBtn){
        titleView.hidden = YES;
        contentView.hidden = YES;
        receiptType = @"";
    }else{
        titleView.hidden = NO;
        contentView.hidden = NO;
        receiptType = button.titleLabel.text;
    }
}

- (IBAction)selectContent:(id)sender{
    UIButton *button = (UIButton *)sender;
    for (UIView *v in contentView.subviews) {
        if([v isKindOfClass:[UIButton class]]){
            UIButton *btn = (UIButton *)v;
            [btn setSelected:NO];
        }
    }
    [button setSelected:YES];
    receiptContent = button.titleLabel.text;
}

//点击键盘上的Return按钮响应的方法
-(IBAction)returnOnKeyboard:(UITextField *)sender{
    [self hideKeyboard];
}

- (void) hideKeyboard{
    [titleTextField resignFirstResponder];
}

- (void)touchOther:(UITapGestureRecognizer *)gesture{
    [self hideKeyboard];
}

- (IBAction)OK:(id)sender{
    if(receiptType.length > 0 && [titleTextField.text length] == 0){
        [SVProgressHUD setErrorImage:nil];
        [SVProgressHUD showErrorWithStatus:@"请输入发票抬头！" maskType:SVProgressHUDMaskTypeBlack];
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:receiptType, @"type", titleTextField.text, @"title", receiptContent, @"content", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:nSelectReceipt object:nil userInfo:userInfo];
    [self dismissViewControllerAnimated:YES completion:nil];

}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
