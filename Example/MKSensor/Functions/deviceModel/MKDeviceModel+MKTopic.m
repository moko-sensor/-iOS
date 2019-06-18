//
//  MKDeviceModel+MKTopic.m
//  MKSmartPlug
//
//  Created by aa on 2018/9/8.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel+MKTopic.h"

NSString *const smartSensorWifiSSIDKey = @"ED";

@implementation MKDeviceModel (MKTopic)

/**
 是否已经连接到正确的wifi了，点击连接的时候，必须先连接设备的wifi，然后把mqtt服务器参数和周围可用的wifi信息设置给wifi之后才进行mqtt服务器的连接
 
 @return YES:target,NO:not target
 */
+ (BOOL)currentWifiIsCorrect{
    if ([MKNetworkManager sharedInstance].currentNetStatus != AFNetworkReachabilityStatusReachableViaWiFi) {
        return NO;
    }
    NSString *wifiSSID = [MKNetworkManager currentWifiSSID];
    if (!ValidStr(wifiSSID) || [wifiSSID isEqualToString:@"<<NONE>>"]) {
        //当前wifi的ssid未知
        return NO;
    }
    
    if (wifiSSID.length < smartSensorWifiSSIDKey.length) {
        return NO;
    }
    NSString *ssidHeader = [[wifiSSID substringWithRange:NSMakeRange(0, smartSensorWifiSSIDKey.length)] uppercaseString];
    if ([ssidHeader isEqualToString:smartSensorWifiSSIDKey]) {
        return YES;
    }
    return NO;
}

/**
 订阅的主题
 
 @param topicType 主题类型，是app发布数据的主题还是设备发布数据的主题
 @param function 主题功能
 @return 设备功能/设备名称/型号/mac/topicType/function
 */
- (NSString *)subscribeTopicInfoWithType:(deviceModelTopicType)topicType
                                function:(NSString *)function{
    NSString *typeIden = (topicType == deviceModelTopicDeviceType ? @"device" : @"app");
    return [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@",
            self.device_function,
            self.device_name,
            self.device_specifications,
            self.device_mac,
            typeIden,
            function];
}

/**
 app可以订阅的主题
 
 @return topicList
 */
- (NSArray <NSString *>*)allTopicList{
    NSString *deviceInfo = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"device_info"];
    NSString *heartbeat = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"heartbeat"];
    NSString *deleteDevice = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"delete_device"];
    NSString *sensor = [self subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"sensor_data"];
    NSMutableArray *topicList = [NSMutableArray array];
    [topicList addObject:deviceInfo];
    [topicList addObject:heartbeat];
    [topicList addObject:deleteDevice];
    [topicList addObject:sensor];
    return [topicList copy];
}

@end
