//
//  DateHelper.m
//  JavaMall
//
//  Created by Dawei on 7/1/15.
//  Copyright (c) 2015 Enation. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper

+ (NSDate *) unixtimeToDate:(double) unixtime{
    NSTimeInterval _interval = unixtime;
    return [NSDate dateWithTimeIntervalSince1970:_interval];    
}

+ (NSString *) dateToString:(NSDate *) date withFormat:(NSString *)format{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *) unixtimeToString:(double) unixtime withFormat:(NSString *)format{
    return [DateHelper dateToString:[DateHelper unixtimeToDate:unixtime] withFormat:format];
}

@end
