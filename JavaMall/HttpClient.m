//
//  HttpClient.m
//  Assistant
//
//  Created by Dawei on 4/10/15.
//
//

#import "Defines.h"
#import "HttpClient.h"
#import "AFNetworking.h"

@implementation HttpClient

/**
 *  初始化
 *
 *  @return HttpClient对象
 */
-(id) init{
    if(self = [super init]){
    }
    return self;
}

/**
 *  Http Get方法
 *
 *  @param url 要请求的网址
 *
 *  @return 网页源代码
 */
- (NSString *)get:(NSString *)url{
    return [self get:url useEncoding:0];
}

/**
 *  Http Get方法
 *
 *  @param url      要请求的网址
 *  @param encoding 编码，如果不想传编码，则设置为0即可
 *
 *  @return 网页源代码
 */
- (NSString *)get:(NSString *)url useEncoding:(NSStringEncoding)encoding{
    return [self get:url useEncoding:encoding byReferer:url];
}

/**
 *  Http Get方法
 *
 *  @param url      要请求的网址
 *  @param encoding 编码，如果不想传编码，则设置为0即可
 *  @param referer  来源页
 *
 *  @return 网页源代码
 */
- (NSString *)get:(NSString *)url useEncoding:(NSStringEncoding)encoding byReferer:(NSString *)referer{
    //构造request参数
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    if(referer != nil && ![referer isEqualToString:@""]){
        [requestSerializer setValue:referer forHTTPHeaderField:@"Referer"];
    }
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:url parameters:nil error:nil];
    
    return [self invoke:request withUrl:url andEncoding:encoding];
}

/**
 *  Http Post方法
 *
 *  @param url  要请求的网址
 *  @param data 要Post的数据
 *
 *  @return 网页源代码
 */
- (NSString *)post:(NSString *)url withData:(NSMutableDictionary *)data{
    return [self post:url useEncoding:0 withData:data];
}

/**
 *  Http Post方法
 *
 *  @param url      要请求的网址
 *  @param encoding 网页编码，如果不想设置，则传入0即可
 *  @param data     要Post的数据
 *
 *  @return 网页源代码
 */
- (NSString *)post:(NSString *)url useEncoding:(NSStringEncoding)encoding withData:(NSMutableDictionary *)data{
    return [self post:url useEncoding:encoding withData:data byReferer:nil];
}

/**
 *  Http Post方法
 *
 *  @param url      要请求的网址
 *  @param encoding 网页编码，如果不想设置，则传入0即可
 *  @param data     要Post的数据
 *  @param referer  来源页
 *
 *  @return 网页源代码
 */
- (NSString *)post:(NSString *)url useEncoding:(NSStringEncoding)encoding withData:(NSMutableDictionary *)data byReferer:(NSString *)referer{
    AFHTTPRequestSerializer *requestSerializer = [AFHTTPRequestSerializer serializer];
    [requestSerializer setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/41.0.2272.118 Safari/537.36" forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Contsetent-Type"];
    if(referer != nil && ![referer isEqualToString:@""]){
        [requestSerializer setValue:referer forHTTPHeaderField:@"Referer"];
    }
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"POST" URLString:url parameters:data error:nil];
    
    return [self invoke:request withUrl:url andEncoding:encoding];
}

/**
 *  发送Http请求
 *
 *  @param request  NSMutableRequest对象
 *  @param url      要请求的网址
 *  @param encoding 编码
 *
 *  @return 网页源代码
 */
- (NSString *)invoke:(NSMutableURLRequest *)request withUrl:(NSString *)url andEncoding:(NSStringEncoding)encoding {
    //读取共享cookie
    NSData *cookiesdata = [[NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultsCookie];
    if([cookiesdata length]) {
        NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithData:cookiesdata];
        NSHTTPCookie *cookie;
        for (cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }  
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setResponseSerializer:responseSerializer];
    [operation start];
    [operation waitUntilFinished];
    
    //保存Cookie到共享
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL: [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:cookies];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:kUserDefaultsCookie];
    
    if(encoding != 0){
        return [[NSString alloc] initWithData:[operation responseObject] encoding:encoding];
    }else{
        return [operation responseString];
    }
}
@end
