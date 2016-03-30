//
//  HttpClient.h
//  Assistant
//
//  Created by Dawei on 4/10/15.
//
//

#import "Defines.h"

@protocol HttpClientProtocol

/**
 *  Http Get方法
 *
 *  @param url 要请求的网址
 *
 *  @return HttpResult对象
 */
- (NSString *)get:(NSString *)url;

/**
 *  Http Get方法
 *
 *  @param url      要请求的网址
 *  @param encoding 编码，如果不想传编码，则设置为0即可
 *
 *  @return HttpResult对象
 */
- (NSString *)get:(NSString *)url useEncoding:(NSStringEncoding)encoding;

/**
 *  Http Get方法
 *
 *  @param url      要请求的网址
 *  @param encoding 编码，如果不想传编码，则设置为0即可
 *  @param referer  来源页
 *
 *  @return 网页源代码
 */
- (NSString *)get:(NSString *)url useEncoding:(NSStringEncoding)encoding byReferer:(NSString *)referer;


/**
 *  Http Post方法
 *
 *  @param url  要请求的网址
 *  @param data 要Post的数据
 *
 *  @return 网页源代码
 */
- (NSString *)post:(NSString *)url withData:(NSMutableDictionary *)data;

/**
 *  Http Post方法
 *
 *  @param url      要请求的网址
 *  @param encoding 网页编码，如果不想设置，则传入0即可
 *  @param data     要Post的数据
 *
 *  @return 网页源代码
 */
- (NSString *)post:(NSString *)url useEncoding:(NSStringEncoding)encoding withData:(NSMutableDictionary *)data;

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
- (NSString *)post:(NSString *)url useEncoding:(NSStringEncoding)encoding withData:(NSMutableDictionary *)data byReferer:(NSString *)referer;


@end

@interface HttpClient : NSObject <HttpClientProtocol>
@end
