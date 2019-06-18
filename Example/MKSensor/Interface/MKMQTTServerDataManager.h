//
//  MKMQTTServerDataManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
 mqtt服务器连接状态改变
 */
extern NSString *const MKMQTTSessionManagerStateChangedNotification;

/*
 接收到传感器数据的通知
 */
extern NSString *const MKMQTTServerReceivedSensorDataNotification;

/*
 接收到电量信息通知
 */
extern NSString *const MKMQTTServerReceivedElectricityNotification;

/*
 接收到设备固件信息通知
 */
extern NSString *const MKMQTTServerReceivedFirmwareInfoNotification;

/*
 接收到设备固件升级结果通知
 */
extern NSString *const MKMQTTServerReceivedUpdateResultNotification;

/*
 接收到设备心跳包
 */
extern NSString *const MKMQTTServerReceivedHeartBeatNotification;

@class MKConfigServerModel;
@interface MKMQTTServerDataManager : NSObject

@property (nonatomic, strong, readonly)MKConfigServerModel *configServerModel;

@property (nonatomic, assign, readonly)MKMQTTSessionManagerState state;

+ (MKMQTTServerDataManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接mqtt server

 */
- (void)connectServer;

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData;

@end
