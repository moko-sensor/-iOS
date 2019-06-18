//
//  MKSmartPlugConnectManager.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKConfigServerModel;
@interface MKSmartPlugConnectManager : NSObject

@property (nonatomic, strong, readonly)MKConfigServerModel *configServerModel;

+ (MKSmartPlugConnectManager *)sharedInstance;

- (void)saveServerConfigDataToLocal:(MKConfigServerModel *)model;

/**
 清除本地记录的设置信息
 */
- (void)clearLocalData;

/**
 记录到本地
 */
- (void)synchronize;

/**
 连接sensor设备并且配置各项参数过程，配置成功之后，该设备会存储到本地数据库.

 @param wordMode 设备用哪种方式跟服务器通信.
 sensorWorkWithGPRSMode:通过gprs模式通信，这个时候wifi_ssid和password参数不需要.
 sensorWorkWithWifiMode:通过wifi方式通信，则wifi_ssid和password参数不能为空.
 
 @param wifi_ssid 指定sensor连接的wifi ssid(wordMode==sensorWorkWithGPRSMode可以为空)
 @param password 指定sensor连接的wifi password，对于没有密码的wifi，该项参数可以不填(wordMode==sensorWorkWithGPRSMode可以为空)
 @param sucBlock 成功回调
 @param failedBlock 失败回调
 */
- (void)configDevice:(sensorWorkMode)wordMode
            wifiSSID:(NSString *)wifi_ssid
            password:(NSString *)password
            sucBlock:(void (^)(NSDictionary *deviceInfo))sucBlock
         failedBlock:(void (^)(NSError *error))failedBlock;

@end
