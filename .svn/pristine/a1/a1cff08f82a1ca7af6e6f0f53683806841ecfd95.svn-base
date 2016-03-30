//
//  AdViewController.m
//  JavaMall
//
//  Created by Dawei on 7/20/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "AdViewController.h"
#import "UIImageView+WebCache.h"
#import "HttpClient.h"

@interface AdViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *adImage;
- (IBAction)skip:(id)sender;

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadAd];
}

/**
 *  载入广告信息
 */
- (void) loadAd{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       HttpClient *client = [[HttpClient alloc] init];
                       NSString *content = [client get:[BASE_URL stringByAppendingFormat:@"/api/mobile/adv!getOneAdv.do?advid=%@", AD_ID]];
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if([content length] == 0){
                               [self skip:nil];
                               return;
                           }
                           
                           NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[content dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
                           NSDictionary *data = [result objectForKey:@"data"];
                           if(data == nil){
                               [self skip:nil];
                               return;
                           }
                           [self loadImage:[data objectForKey:@"atturl"]];
                       });
                   });
}

/**
 *  载入图片
 *
 *  @param url 图片网址
 */
- (void) loadImage:(NSString *) url{
    [self.adImage sd_setImageWithURL:[NSURL URLWithString:url]
                    placeholderImage:nil
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                               [self performSelector:@selector(skip:) withObject:nil afterDelay:3];
                           }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)skip:(id)sender {
    [self presentViewController:[super controllerFromMainStroryBoard:@"Main"] animated:YES completion:nil];
}
@end
