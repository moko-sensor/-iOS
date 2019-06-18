//
//  MKHexKeyboard.h
//  FitPolo
//
//  Created by aa on 2018/3/22.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^MKHexKeyboardInputValueChangedBlock)(NSString *keyboardValue);

@interface MKHexKeyboard : UIView

/**
 键盘最大输出长度
 */
@property (nonatomic, assign)NSInteger maxOutputLen;

- (void)showHexKeyboardBlock:(MKHexKeyboardInputValueChangedBlock)block;

@end
