//
//  MKDeviceModel.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/9.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceModel.h"

@implementation mk_deviceTypeModel

- (void)updateTypeModel:(NSDictionary *)dic{
    if (!ValidDict(dic)) {
        return;
    }
    self.humidity = ([dic[@"humidity"] integerValue] == 1);
    self.env_temp = ([dic[@"env_temp"] integerValue] == 1);
    self.PM2_5 = ([dic[@"PM2_5"] integerValue] == 1);
    self.NH3 = ([dic[@"NH3"] integerValue] == 1);
    self.CO2 = ([dic[@"CO2"] integerValue] == 1);
    self.distance = ([dic[@"distance"] integerValue] == 1);
    self.illumination = ([dic[@"illumination"] integerValue] == 1);
    self.VOC = ([dic[@"VOC"] integerValue] == 1);
    self.infra_red_temp = ([dic[@"infra_red_temp"] integerValue] == 1);
}

- (NSString *)dbSaveString{
    NSDictionary *dic = @{
                          @"humidity":@(self.humidity),
                          @"env_temp":@(self.env_temp),
                          @"PM2_5":@(self.PM2_5),
                          @"NH3":@(self.NH3),
                          @"CO2":@(self.CO2),
                          @"distance":@(self.distance),
                          @"illumination":@(self.illumination),
                          @"VOC":@(self.VOC),
                          @"infra_red_temp":@(self.infra_red_temp),
                          };
    return [dic jsonStringEncoded];
}

@end

@interface MKDeviceModel()

/**
 超过40s没有接收到信息，则认为离线
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

/**
 是否处于离线状态
 */
@property (nonatomic, assign)BOOL offline;

@end

@implementation MKDeviceModel

- (void)dealloc{
    NSLog(@"MKDeviceModel销毁");
}

#pragma mark - MKDeviceModelProtocol

- (void)updatePropertyWithModel:(MKDeviceModel *)model{
    if (!model) {
        return;
    }
    self.device_function = model.device_function;
    self.device_name = model.device_name;
    self.device_specifications = model.device_specifications;
    self.device_mac = model.device_mac;
    self.device_GPRS = model.device_GPRS;
    self.deviceTypeModel = model.deviceTypeModel;
    self.local_name = model.local_name;
    self.sensorState = model.sensorState;
}

- (void)startStateMonitoringTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.offline = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 62.f) {
            //接受数据超时
            dispatch_cancel(weakSelf.receiveTimer);
            weakSelf.receiveTimerCount = 0;
            weakSelf.offline = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([weakSelf.delegate respondsToSelector:@selector(deviceModelStateChanged:)]) {
                    [weakSelf.delegate deviceModelStateChanged:weakSelf];
                }
            });
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter{
    if (self.offline) {
        //已经离线，重新开启定时器监测
        [self startStateMonitoringTimer];
        return;
    }
    self.receiveTimerCount = 0;
}

/**
 取消定时器
 */
- (void)cancel{
    self.receiveTimerCount = 0;
    self.offline = NO;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
}

- (void)updateModel:(NSDictionary *)json{
    if (!ValidDict(json)) {
        return;
    }
    [self modelSetWithJSON:json];
    mk_deviceTypeModel *typeModel = [[mk_deviceTypeModel alloc] init];
    [typeModel updateTypeModel:json[@"device_type"]];
    self.deviceTypeModel = typeModel;
}

@end
