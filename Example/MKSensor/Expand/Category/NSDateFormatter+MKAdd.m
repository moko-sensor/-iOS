//
//  NSDateFormatter+MKAdd.m
//  FitPolo
//
//  Created by aa on 2017/10/13.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "NSDateFormatter+MKAdd.h"
#import <objc/runtime.h>

@implementation NSDateFormatter (MKAdd)

+ (void)load{
    Method sysMethod = class_getInstanceMethod([self class], @selector(init));
    Method customMethod = class_getInstanceMethod([self class], @selector(MK_init));
    
    BOOL didAddMethod = class_addMethod([self class], @selector(init), method_getImplementation(customMethod), method_getTypeEncoding(customMethod));
    if (didAddMethod) {
        //如果方法已经存在，则替换
        class_replaceMethod([self class], @selector(MK_init), method_getImplementation(sysMethod), method_getTypeEncoding(sysMethod));
    }else{
        //
        method_exchangeImplementations(sysMethod, customMethod);
    }
    
    //----------------以上主要是实现两个方法的互换,load是gcd的只shareinstance，果断保证执行一次
}

- (instancetype)MK_init{
    [self MK_init];
    self.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    //语言习惯
    NSLocale *usLocale = [[NSLocale alloc]initWithLocaleIdentifier:@"en_US"];
    self.locale = usLocale;
    return self;
}

@end
