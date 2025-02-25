//
//  UITextField+MKAdd.m
//  FitPolo
//
//  Created by aa on 2017/11/27.
//  Copyright © 2017年 MK. All rights reserved.
//

#import "UITextField+MKAdd.h"
#import <objc/runtime.h>

@implementation UITextField (MKAdd)

+ (void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class class = [self class];
            // When swizzling a class method, use the following:
            // Class class = object_getClass((id)self);
            SEL originalSelector = @selector(init);
            SEL swizzledSelector = @selector(MK_init);
            Method originalMethod = class_getInstanceMethod(class, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
            BOOL didAddMethod = class_addMethod(class,
                                                originalSelector,
                                                method_getImplementation(swizzledMethod),
                                                method_getTypeEncoding(swizzledMethod));
            if (didAddMethod) {
                class_replaceMethod(class,
                                    swizzledSelector,
                                    method_getImplementation(originalMethod),
                                    method_getTypeEncoding(originalMethod));
            } else {
                method_exchangeImplementations(originalMethod, swizzledMethod);
            }
        });
    });
}

- (instancetype)MK_init{
    [self MK_init];
    //去掉预测输入
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    return self;
}

@end
