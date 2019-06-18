//
//  MKDeviceModel.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKDeviceNormalDefines.h"

@interface mk_deviceTypeModel : NSObject

/**
 湿度传感器,取值：0~1；0：没有此传感器 ；1：有此传感器
 */
@property (nonatomic, assign)BOOL humidity;

/**
 温湿度传感器,取值：0~1；0：没有此传感器 ；1：有此传感器
 */
@property (nonatomic, assign)BOOL env_temp;

/**
 取值：0~1；0：没有此传感器 ；1：有此传感器
 */
@property (nonatomic, assign)BOOL PM2_5;

@property (nonatomic, assign)BOOL NH3;

@property (nonatomic, assign)BOOL CO2;

@property (nonatomic, assign)BOOL distance;

@property (nonatomic, assign)BOOL illumination;

@property (nonatomic, assign)BOOL VOC;

@property (nonatomic, assign)BOOL infra_red_temp;

- (void)updateTypeModel:(NSDictionary *)dic;

/**
 入库的时候存储成对应的json字符串

 @return string
 */
- (NSString *)dbSaveString;

@end

@interface MKDeviceModel : NSObject<MKDeviceModelProtocol>

/**
 设备功能
 */
@property (nonatomic, copy)NSString *device_function;

/**
 设备返回的名字
 */
@property (nonatomic, copy)NSString *device_name;

/**
 规格，国标cn/美规us/英规bu/欧规eu
 */
@property (nonatomic, copy)NSString *device_specifications;

/**
 设备id，plug的mac address
 */
@property (nonatomic, copy)NSString *device_mac;

/**
 GPRS的信息，1:设备携带电话卡，0：设备不携带电话卡
 */
@property (nonatomic, assign)NSInteger device_GPRS;

@property (nonatomic, strong)mk_deviceTypeModel *deviceTypeModel;



/**
 用户手动添加的在设备列表页面显示的设备名字，device_name是plug自己定义的并且不可修改的字段。如果用户没有添加这个local_name，那么默认的值就是xxxx
 */
@property (nonatomic, copy)NSString *local_name;

/**
 智能插座当前设备的状态，离线、开、关
 */
@property (nonatomic, assign)MKSmartPlugState sensorState;

#pragma mark - 业务流程相关

@property (nonatomic, weak)id <MKDeviceModelDelegate>delegate;

- (void)updateModel:(NSDictionary *)json;

@end
