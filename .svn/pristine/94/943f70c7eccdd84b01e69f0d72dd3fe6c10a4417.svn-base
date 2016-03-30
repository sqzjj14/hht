//
//  GoodsViewController.m
//  JavaMall
//
//  Created by Dawei on 6/28/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "GoodsViewController.h"
#import "UIColor+HexString.h"
#import "ImagePlayerView.h"
#import "MSViewControllerSlidingPanel.h"
#import "HttpClient.h"
#import "SVProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "SpecViewController.h"
#import "GoodsDetailViewController.h"
#import "GoodsCommentViewController.h"

@interface GoodsViewController ()
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *specView;
@property (weak, nonatomic) IBOutlet UIView *stockView;
@property (weak, nonatomic) IBOutlet UIView *weightView;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storeConstraint;

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *price;
@property (weak, nonatomic) IBOutlet UILabel *spec;
@property (weak, nonatomic) IBOutlet UILabel *stock;
@property (weak, nonatomic) IBOutlet UILabel *stockStatus;
@property (weak, nonatomic) IBOutlet UILabel *weight;
@property (weak, nonatomic) IBOutlet UILabel *commentPercent;
@property (weak, nonatomic) IBOutlet UILabel *comment;
- (IBAction)back:(id)sender;

@end

@implementation GoodsViewController{
    NSMutableArray *imageURLs;
    NSMutableArray *photos;
    
    UIButton *favoriteBtn;
    UIButton *cartBtn;
    UIButton *addToCartBtn;
    ImagePlayerView *imagePlayerView;
    
    //购物车角标
    UILabel *badgeLabel;
    
    HttpClient *client;
    
    NSMutableDictionary *product;
    NSString *imageUrl;
    int count;
}

@synthesize goods_id, act_id, groupbuy_id;
@synthesize headerView, scrollView, nameView, specView, stockView, weightView, commentView;
@synthesize name, price, spec, stock, stockStatus, weight, commentPercent, comment;
@synthesize priceConstraint, storeConstraint;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //StatusBar背景色
    [super setStatusBarBackgroudColor:[UIColor colorWithHexString:@"#FAFAFA"]];
    
    imageURLs = [NSMutableArray arrayWithCapacity:0];
    client = [[HttpClient alloc] init];
    
    UITapGestureRecognizer *specTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [specTapGesture setNumberOfTapsRequired:1];
    [specView addGestureRecognizer:specTapGesture];
    
    UITapGestureRecognizer *nameTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [nameTapGesture setNumberOfTapsRequired:1];
    [nameView addGestureRecognizer:nameTapGesture];
    
    UITapGestureRecognizer *commentTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapEvent:)];
    [commentTapGesture setNumberOfTapsRequired:1];
    [commentView addGestureRecognizer:commentTapGesture];
    
    imagePlayerView = [[ImagePlayerView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 300)];
    imagePlayerView.imagePlayerViewDelegate = self;
    imagePlayerView.scrollInterval = 60.0f;
    imagePlayerView.pageControlPosition = ICPageControlPosition_BottomCenter;
    imagePlayerView.hidePageControl = NO;
    
    [self.scrollView addSubview:imagePlayerView];
    
    [self initOperateView];    
    [self loadGoods];
    [self loadGallery];
}

- (void)viewWillAppear:(BOOL)animated{
    [self loadCartCount];
}

- (void) initOperateView{
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 45, kScreenWidth, 45)];
    [bottomView setBackgroundColor:[UIColor blackColor]];
    [bottomView setAlpha:0.9f];
    
    favoriteBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 68, 45)];
    [favoriteBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [favoriteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [favoriteBtn setImage:[UIImage imageNamed:@"pd_collect.png"] forState:UIControlStateNormal];
    [favoriteBtn setImageEdgeInsets:UIEdgeInsetsMake(-10, 21, 0, 0)];
    [favoriteBtn setTitleEdgeInsets:UIEdgeInsetsMake(28, -14, 0, 0)];
    [favoriteBtn setAdjustsImageWhenHighlighted:NO];
    favoriteBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [favoriteBtn addTarget:self action:@selector(favorite) forControlEvents:UIControlEventTouchUpInside];
    
    cartBtn = [[UIButton alloc] initWithFrame:CGRectMake((kScreenWidth - 150) / 2, 0, 68, 45)];
    [cartBtn setTitle:@"购物车" forState:UIControlStateNormal];
    [cartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cartBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [cartBtn setImage:[UIImage imageNamed:@"pd_cart.png"] forState:UIControlStateNormal];
    [cartBtn setImageEdgeInsets:UIEdgeInsetsMake(-10, 21, 0, 0)];
    [cartBtn setTitleEdgeInsets:UIEdgeInsetsMake(28, -14, 0, 0)];
    [cartBtn addTarget:self action:@selector(go2Cart) forControlEvents:UIControlEventTouchUpInside];

    
    UIView *addToCartView = [[UIView alloc] initWithFrame:CGRectMake(kScreenWidth-150, 0, 150, 45)];
    addToCartView.backgroundColor = [UIColor colorWithHexString:@"#f15352"];
    addToCartBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 3, 150, 45)];
    [addToCartBtn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [addToCartBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addToCartBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    if(act_id > 0){
        [addToCartBtn addTarget:self action:@selector(addSeckillToCart) forControlEvents:UIControlEventTouchUpInside];
    }else {
        [addToCartBtn addTarget:self action:@selector(addToCart) forControlEvents:UIControlEventTouchUpInside];
    }
    [addToCartView addSubview:addToCartBtn];

    [bottomView addSubview:favoriteBtn];
    [bottomView addSubview:cartBtn];
    [bottomView addSubview:addToCartView];
    [self.view addSubview:bottomView];
}

/**
 *  点击手势
 *
 *  @param gesture
 */
- (void)tapEvent:(UITapGestureRecognizer *)gesture{
    if(gesture.view == specView){
        SpecViewController *specViewController = (SpecViewController *)[self slidingPanelController].rightPanelController;
        specViewController.product = product;
        [specViewController loadData];
        [[self slidingPanelController] openRightPanel];
    }else if(gesture.view == nameView){
        GoodsDetailViewController *goodsDetailViewController = (GoodsDetailViewController *)[super controllerFromMainStroryBoard:@"GoodsDetail"];
        goodsDetailViewController.goods_id = goods_id;
        goodsDetailViewController.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:goodsDetailViewController animated:YES];
    }else if(gesture.view == commentView){
        GoodsCommentViewController *goodsCommentViewController = (GoodsCommentViewController *)[super controllerFromMainStroryBoard:@"GoodsComment"];;
        goodsCommentViewController.goods_id = goods_id;
        goodsCommentViewController.hidesBottomBarWhenPushed = YES;
        [[self navigationController] pushViewController:goodsCommentViewController animated:YES];
    }
}

/**
 *  载入商品详细信息
 */
- (void) loadGoods{
    [SVProgressHUD showWithStatus:@"载入中..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!detail.do?id=%d&act_id=%d&groupbuy_id=%d", goods_id, act_id, groupbuy_id]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [SVProgressHUD dismiss];
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"载入失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           product = [NSMutableDictionary dictionaryWithDictionary:[resultJSON objectForKey:@"data"]];
                           imageUrl = [product objectForKey:@"thumbnail"];
                           commentPercent.text = [NSString stringWithFormat:@"好评 %@", [product objectForKey:@"comment_percent"]];
                           comment.text = [NSString stringWithFormat:@"%d 人评价", [[product objectForKey:@"comment_count"] intValue]];
                           count = 1;
                           
                           [self setFavorited:[[product objectForKey:@"favorited"] boolValue]];
                           [self initProduct];
                           [SVProgressHUD dismiss];
                       });
                   });
}

/**
 *  载入相册
 */
- (void) loadGallery{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/goods!gallery.do?id=%d", goods_id]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSArray *images = [resultJSON objectForKey:@"data"];
                           for (NSDictionary *dic in images) {
                               [imageURLs addObject:[dic objectForKey:@"big"]];
                           }
                           
                           [imagePlayerView reloadData];
                       });
                   });

}

/*
 * 载入购物车数量
 */
- (void) loadCartCount{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = [client get:[BASE_URL stringByAppendingString:@"/api/mobile/cart!count.do"]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           if([content length] == 0){
                               [self updateCartBadge:0];
                               return;
                           }
                           
                           NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([resultJSON objectForKey:@"count"] != nil){
                               [self updateCartBadge:[[resultJSON objectForKey:@"count"] intValue]];
                               return;
                           }
                           [self updateCartBadge:0];
                       });
                   });

}

/*
 * 更新购物车角标
 */
- (void) updateCartBadge:(int) _count{
    if (_count <= 0) {
        if(badgeLabel != nil){
            badgeLabel.hidden = YES;
        }
        return;
    }
    if(badgeLabel == nil){
        //购物车角标
        badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 5, 20, 14)];
        [badgeLabel setFont:[UIFont systemFontOfSize:12]];
        [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
        [badgeLabel setBackgroundColor:[UIColor redColor]];
        [badgeLabel setTextColor:[UIColor whiteColor]];
        [badgeLabel setTextAlignment:NSTextAlignmentCenter];
        badgeLabel.layer.cornerRadius = 6;
        badgeLabel.layer.masksToBounds = YES;
        [cartBtn addSubview:badgeLabel];
        return;
    }
    [badgeLabel setText:[NSString stringWithFormat:@"%d", _count]];
    badgeLabel.hidden = NO;
}

/**
 *  填充商品信息
 */
- (void) initProduct{
    name.text = [product objectForKey:@"name"];

    if([[product objectForKey:@"specs"] isKindOfClass:[NSString class]]){
        spec.text = [NSString stringWithFormat:@"%@ (%d件)", [product objectForKey:@"specs"], count];
    }else{
        spec.text = [NSString stringWithFormat:@"%d件", count];
    }
    int stockCount = [[product objectForKey:@"store"] intValue];
    stock.text = [NSString stringWithFormat:@"%d", stockCount];
    if(stockCount == 0){
        stockStatus.hidden = NO;
    }else{
        stockStatus.hidden = YES;
    }
    weight.text = [NSString stringWithFormat:@"%@ g", [product objectForKey:@"weight"]];


    NSString *priceText = [NSString stringWithFormat:@"￥%@", [product objectForKey:@"price"]];
    //团购
    if(groupbuy_id > 0){
        priceText = [NSString stringWithFormat:@"团购价: %@", priceText];
        storeConstraint.constant = -40;
    }

    price.text = priceText;

    CGSize size = [priceText sizeWithFont:price.font constrainedToSize:CGSizeMake(price.frame.size.width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    priceConstraint.constant = size.width + 10;

    if(act_id > 0){
        UIImageView *skillImage = [[UIImageView alloc] initWithFrame:CGRectMake(price.frame.origin.x + size.width + 5, price.frame.origin.y, 55, 16)];
        skillImage.image = [UIImage imageNamed:@"seckill"];
        [nameView addSubview:skillImage];
        storeConstraint.constant = -40;
    }
    
    SpecViewController *specViewController = (SpecViewController *)[self slidingPanelController].rightPanelController;
    specViewController.product = product;
    [specViewController loadData];
}

- (void) setProduct:(NSDictionary *) _product count:(int) _count{
    [product setValue:[_product objectForKey:@"name"] forKey:@"name"];
    [product setValue:[_product objectForKey:@"enable_store"] forKey:@"enable_store"];
    [product setValue:[_product objectForKey:@"price"] forKey:@"price"];
    [product setValue:[_product objectForKey:@"product_id"] forKey:@"product_id"];
    [product setValue:[_product objectForKey:@"sn"] forKey:@"sn"];
    [product setValue:[_product objectForKey:@"specs"] forKey:@"specs"];
    [product setValue:[_product objectForKey:@"store"] forKey:@"store"];
    [product setValue:[_product objectForKey:@"weight"] forKey:@"weight"];
    count = _count;
    [self initProduct];
}

/**
*  添加秒杀商品到购物车
*/
- (void) addSeckillToCart {
    [SVProgressHUD showWithStatus:@"正在秒杀…" maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
            ^{
                NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/seckill/seckillCart!addGoods.do?goodsid=%d&num=1", [[product objectForKey:@"goods_id"] intValue]]];
                dispatch_async(dispatch_get_main_queue(), ^{

                    [SVProgressHUD dismiss];

                    if([content length] == 0){
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"秒杀失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alertView show];
                        return;
                    }

                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                    if([[result objectForKey:@"result"] intValue] == -1){
                        [SVProgressHUD setErrorImage:nil];
                        [SVProgressHUD showErrorWithStatus:@"秒杀失败！" maskType:SVProgressHUDMaskTypeBlack];
                        return;
                    }

                    if([[result objectForKey:@"result"] intValue] == 0){
                        [SVProgressHUD setErrorImage:nil];
                        [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                        return;
                    }
                    [SVProgressHUD setInfoImage:nil];
                    [SVProgressHUD showInfoWithStatus:@"秒杀成功！" maskType:SVProgressHUDMaskTypeBlack];
                    [self loadCartCount];
                });
            });

}

/**
 * 添加批定数量的商品到购物车
 */
- (void) addToCart:(int) _count{
    count = _count;
    [self addToCart];
}

/**
 *  添加到购物车
 */
- (void) addToCart {
    [SVProgressHUD showWithStatus:@"正在加入购物车..." maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *content = @"";
                       NSString *specs = [product objectForKey:@"specs"];
                       
                       if([specs isKindOfClass:[NSNull class]] || specs.length == 0 || [specs isEqualToString:@"null"]){
                           content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/cart!add.do?productid=%d&num=%d", [[product objectForKey:@"product_id"] intValue], count]];
                       }else{
                           content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/cart!add.do?havespec=1&productid=%d&num=%d", [[product objectForKey:@"product_id"] intValue], count]];
                       }
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"添加到购物车失败！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == -1){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"添加到购物车失败！" maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[result objectForKey:@"message"] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           [SVProgressHUD setInfoImage:nil];
                           [SVProgressHUD showInfoWithStatus:@"添加成功！" maskType:SVProgressHUDMaskTypeBlack];
                           [self loadCartCount];
                       });
                   });

}

/**
 *  进入购物车
 */
- (void) go2Cart{
    [[self navigationController] pushViewController:[super controllerFromMainStroryBoard:@"Cart"] animated:YES];
}

/**
 *  收藏
 */
- (void) favorite{
    if([super isLogined] == NO){
        [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
        return;
    }
    NSString *operationText = favoriteBtn.tag == 1 ? @"取消收藏" : @"收藏";
    [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"正在%@...", operationText] maskType:SVProgressHUDMaskTypeBlack];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       NSString *param = favoriteBtn.tag == 1 ? [NSString stringWithFormat:@"/api/mobile/favorite!delete.do?id=%d", goods_id] : [NSString stringWithFormat:@"/api/mobile/favorite!add.do?id=%d", goods_id];
                       NSString *content = [client get:[BASE_URL stringByAppendingString:param]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           [SVProgressHUD dismiss];
                           
                           if([content length] == 0){
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@失败", operationText] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                               [alertView show];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           if([[result objectForKey:@"result"] intValue] == -1){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:@"未登录或登录已过期，请重新登录！" maskType:SVProgressHUDMaskTypeBlack];
                               [self presentViewController:[super controllerFromMainStroryBoard:@"Login"] animated:YES completion:nil];
                               return;
                           }
                           
                           if([[result objectForKey:@"result"] intValue] == 0){
                               [SVProgressHUD setErrorImage:nil];
                               [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@失败，请您重试！", operationText] maskType:SVProgressHUDMaskTypeBlack];
                               return;
                           }
                           [SVProgressHUD setInfoImage:nil];
                           [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@成功！", operationText] maskType:SVProgressHUDMaskTypeBlack];
                           if(favoriteBtn.tag == 1){
                               [self setFavorited:NO];
                           }else{
                               [self setFavorited:YES];
                           }
                       });
                   });
}

- (void) setFavorited:(BOOL) _favorited{
    if(_favorited){
        [favoriteBtn setTitle:@"已收藏" forState:UIControlStateNormal];
        [favoriteBtn setImage:[UIImage imageNamed:@"pd_collected.png"] forState:UIControlStateNormal];
        favoriteBtn.tag = 1;
        return;
    }
    [favoriteBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [favoriteBtn setImage:[UIImage imageNamed:@"pd_collect.png"] forState:UIControlStateNormal];
    favoriteBtn.tag = 0;

}

#pragma mark - ImagePlayerViewDelegate
- (NSInteger)numberOfItems
{
    return imageURLs.count;
}

- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView loadImageForImageView:(UIImageView *)imageView index:(NSInteger)index{
    [imageView sd_setImageWithURL:[NSURL URLWithString:[imageURLs objectAtIndex:index]]
                 placeholderImage:[UIImage imageNamed:@"image_empty.png"]];
}


- (void)imagePlayerView:(ImagePlayerView *)imagePlayerView didTapAtIndex:(NSInteger)index{
    photos = [NSMutableArray array];
    
    for(int i = 0; i < imageURLs.count; i++){
        [photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:[imageURLs objectAtIndex:i]]]];
    }

    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = YES; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = YES; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    browser.autoPlayOnAppear = NO; // Auto-play first video
    
    // Customise selection images to change colours if required
//    browser.customImageSelectedIconName = @"ImageSelected.png";
//    browser.customImageSelectedSmallIconName = @"ImageSelectedSmall.png";
    
    // Optionally set the current visible photo before displaying
    [browser setCurrentPhotoIndex:index];
    
    // Present
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:nc animated:YES completion:nil];
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return photos.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < photos.count) {
        return [photos objectAtIndex:index];
    }
    return nil;
}

/**
 *  设置头部背景色和下线线
 */
- (void) viewDidLayoutSubviews{
    headerView.backgroundColor = [UIColor colorWithHexString:@"#FAFAFA"];
    [super setBorderWithView:headerView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#cdcdcd"] borderWidth:1];
    [super setBorderWithView:nameView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#f4f4f4"] borderWidth:1];
    [super setBorderWithView:specView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#f4f4f4"] borderWidth:1];
    [super setBorderWithView:stockView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#f4f4f4"] borderWidth:1];
    [super setBorderWithView:weightView top:NO left:NO bottom:YES right:NO borderColor:[UIColor colorWithHexString:@"#f4f4f4"] borderWidth:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)back:(id)sender {
    [[self navigationController] dismissViewControllerAnimated:YES completion:nil];
}
@end
