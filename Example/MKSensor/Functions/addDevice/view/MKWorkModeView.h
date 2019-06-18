//
//  MKWorkModeView.h
//  MKSensor
//
//  Created by aa on 2019/1/10.
//  Copyright © 2019 MK. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MKConnectViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MKWorkModeSelectDelegate <NSObject>

- (void)workModeSelected:(BOOL)isGPRSMode;

@end

@interface MKWorkModeView : UIView<MKConnectViewProtocol>

@property (nonatomic, weak)id <MKWorkModeSelectDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
