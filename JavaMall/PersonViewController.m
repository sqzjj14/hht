//
//  PersonViewController.m
//  JavaMall
//
//  Created by Dawei on 6/26/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "PersonViewController.h"
#import "SVProgressHUD.h"
#import "UIColor+HexString.h"
#include "FontHelper.h"
#import "UIImageView+WebCache.h"
#import "HttpClient.h"
#import "AddressViewController.h"
#import "CouponViewController.h"

@interface PersonViewController()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *orderView;
@property (weak, nonatomic) IBOutlet UIView *favoriteView;
@property (weak, nonatomic) IBOutlet UIView *addressView;
@property (weak, nonatomic) IBOutlet UIView *passwordView;
@property (weak, nonatomic) IBOutlet UIView *logoutView;
//优惠劵
@property (weak, nonatomic) IBOutlet UIView *couponView;

@property (weak, nonatomic) IBOutlet UIView *editView;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *loginConstraint;

@end

@implementation PersonViewController{
    HttpClient *client;
    
    UIView *loginPanel;
}

@synthesize headerView, loginView, orderView, favoriteView, addressView, passwordView, logoutView, editView;

- (void) viewDidLoad {
    [super viewDidLoad];
    
    if ([UIScreen mainScreen].bounds.size.height == 480){
        _loginConstraint.constant = 85;
    }

    //self.dataView.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoutView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.dataView attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:logoutView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.dataView attribute:NSLayoutAttributeTrailing multiplier:1 constant:0]];
    
       
    client = [[HttpClient alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginCompletion:) name:nLogin object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changePasswordCompletion:) name:nChangePassword object:nil];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    UIGraphicsBeginImageContext(loginView.frame.size);
    [[UIImage imageNamed:@"hht_head_background_login.jpg"] drawInRect:loginView.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    loginView.backgroundColor = [UIColor colorWithPatternImage:image];
    [self initLoginView];
    
    UITapGestureRecognizer *logoutTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logout:)];
    [logoutTapGesture setNumberOfTapsRequired:1];
    [logoutView addGestureRecognizer:logoutTapGesture];
    
    UITapGestureRecognizer *orderTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(order:)];
    [orderTapGesture setNumberOfTapsRequired:1];
    [orderView addGestureRecognizer:orderTapGesture];
    
    UITapGestureRecognizer *favoriteTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(favorite:)];
    [favoriteTapGesture setNumberOfTapsRequired:1];
    [favoriteView addGestureRecognizer:favoriteTapGesture];
    
    UITapGestureRecognizer *addressTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(address:)];
    [addressTapGesture setNumberOfTapsRequired:1];
    [addressView addGestureRecognizer:addressTapGesture];
    
    UITapGestureRecognizer *passwordTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(password:)];
    [passwordTapGesture setNumberOfTapsRequired:1];
    [passwordView addGestureRecognizer:passwordTapGesture];
    
    UITapGestureRecognizer *editTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(edit:)];
    [editTapGesture setNumberOfTouchesRequired:1];
    [editView addGestureRecognizer:editTapGesture];
    
    UITapGestureRecognizer *couponTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(coupon:)];
    [couponTapGesture setNumberOfTouchesRequired:1];
    [_couponView addGestureRecognizer:couponTapGesture];
    
}

- (void) initLoginView{
    if(loginPanel != nil){
        [loginPanel removeFromSuperview];
    }
    loginPanel = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, loginView.frame.size.height)];
    if(![super isLogined]){
        NSString *welcome = [NSString stringWithFormat:@"%@%@", @"欢迎来到", SHOP_NAME];
        CGSize welcomeSize = [FontHelper fontSize:18 withString:welcome];
        UILabel *welcomeLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - welcomeSize.width) / 2, 20, welcomeSize.width, welcomeSize.height)];
        welcomeLabel.text = welcome;
        welcomeLabel.font = [UIFont systemFontOfSize:18];
        welcomeLabel.textColor = [UIColor whiteColor];
        [loginPanel addSubview:welcomeLabel];
        
        UIButton *loginBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth-80)/2, 55, 80.5, 32.5)];
        [loginBtn setImage:[UIImage imageNamed:@"my_login_button.png"] forState:UIControlStateNormal];
        [loginBtn addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
        [loginPanel addSubview:loginBtn];
        
        logoutView.hidden = YES;
    }else{
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        UIImageView *face = [[UIImageView alloc] initWithFrame:CGRectMake(20, 22, 60, 60)];
        [face sd_setImageWithURL:[NSURL URLWithString:[defaults objectForKey:@"face"]]
                           placeholderImage:[UIImage imageNamed:@"my_head_default.png"]];

        [loginPanel addSubview:face];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 25, 200, 25)];
        nameLabel.text = [defaults objectForKey:@"username"];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor whiteColor];
        [loginPanel addSubview:nameLabel];
        
        UILabel *levelLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 50, 200, 25)];
        levelLabel.text = [defaults objectForKey:@"level"];
        levelLabel.font = [UIFont systemFontOfSize:14];
        levelLabel.textColor = [UIColor whiteColor];
        [loginPanel addSubview:levelLabel];
        
        logoutView.hidden = NO;
    }
    [loginView addSubview:loginPanel];
}

- (void)logout:(UITapGestureRecognizer *)gesture{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"您确认要退出登录吗？"
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:@"确定"
                                                    otherButtonTitles:nil
                                  ];
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if(buttonIndex !=[actionSheet cancelButtonIndex]){
        [SVProgressHUD showWithStatus:@"正在退出登录..." maskType:SVProgressHUDMaskTypeBlack];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       ^{
                           [client get:[BASE_URL stringByAppendingString:@"/api/mobile/member!logout.do"]];
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [SVProgressHUD dismiss];
                               
                               NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                               [defaults removeObjectForKey:@"username"];
                               [defaults removeObjectForKey:@"face"];
                               [defaults removeObjectForKey:@"level"];
                               [defaults synchronize];

                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"退出登录成功！" maskType:SVProgressHUDMaskTypeBlack];
                               
                               [self initLoginView];
//                               [self.view.window.rootViewController dismissViewControllerAnimated:NO completion:nil];
//                               [self dismissViewControllerAnimated:NO completion:nil];
                             [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                           });
                       });
    }
}

- (void) login{
    [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
}

-(void)loginCompletion:(NSNotification*)notification {
    [self initLoginView];
}


- (void)order:(UITapGestureRecognizer *)gesture{
    if(![super isLogined]){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    [self presentViewController:[super controllerFromMainStroryBoard:@"MyOrder"] animated:YES completion:nil];
}

- (void)favorite:(UITapGestureRecognizer *)gesture{
    if(![super isLogined]){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    [self presentViewController:[super controllerFromMainStroryBoard:@"MyFavorite"] animated:YES completion:nil];
}

- (void)address:(UITapGestureRecognizer *)gesture{
    if(![super isLogined]){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    AddressViewController *addressViewController = (AddressViewController *)[super controllerFromMainStroryBoard:@"Address"];
    addressViewController.type = @"manage";
    [self presentViewController:addressViewController animated:YES completion:nil];
}

- (void)password:(UITapGestureRecognizer *)gesture{
    
    [self presentViewController:[super controllerFromMainStroryBoard:@"Password"] animated:YES completion:nil];
}

-(void)edit:(UITapGestureRecognizer *)gesture{
    
    if(![super isLogined]){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    [self presentViewController:[super controllerFromMainStroryBoard:@"PersonEdit"] animated:YES completion:nil];
}
-(void)coupon:(UITapGestureRecognizer *)gesture{
    
    if(![super isLogined]){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    CouponViewController *vc = (CouponViewController *)[super controllerFromMainStroryBoard:@"Coupon"];
    vc.ispaying = NO;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)changePasswordCompletion:(NSNotification*)notification{
    [self initLoginView];
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:orderView top:YES left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:favoriteView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:addressView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:passwordView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:logoutView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:editView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
    [super setBorderWithView:_couponView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:0.5f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
