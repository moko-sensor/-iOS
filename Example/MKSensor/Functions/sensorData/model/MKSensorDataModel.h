//
//  MKSensorDataModel.h
//  MKSensor
//
//  Created by aa on 2019/1/15.
//  Copyright © 2019 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MKSensorDataModel : NSObject

@property (nonatomic, copy)NSString *leftIconName;

@property (nonatomic, copy)NSString *message;

@property (nonatomic, copy)NSString *value;

@property (nonatomic, assign)BOOL isInvalidData;

@end

NS_ASSUME_NONNULL_END
