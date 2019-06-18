//
//  MKAddDeviceDataManager.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/7.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKAddDeviceDataManager.h"
#import "MKConnectDeviceView.h"
#import "MKConnectDeviceProgressView.h"
#import "MKConnectDeviceWifiView.h"
#import "MKConnectViewProtocol.h"
#import "MKDeviceDataBaseManager.h"
#import "MKWorkModeView.h"

@interface MKAddDeviceDataManager()<MKConnectViewConfirmDelegate,MKWorkModeSelectDelegate>

@property (nonatomic, copy)void (^completeBlock)(NSError *error, BOOL success, MKDeviceModel *deviceModel);

@property (nonatomic, copy)NSString *wifiSSID;

@property (nonatomic, copy)NSString *password;

@property (nonatomic, strong)NSMutableArray *viewList;

@property (nonatomic, strong)NSMutableDictionary *deviceDic;

/**
 超过15s没有接收到连接成功数据，则认为连接失败
 */
@property (nonatomic, strong)dispatch_source_t receiveTimer;

@property (nonatomic, assign)NSInteger receiveTimerCount;

@property (nonatomic, assign)BOOL connectTimeout;

/**
 用户选择的是grps还是wifi
 */
@property (nonatomic, assign)BOOL isGPRSMode;

@end

@implementation MKAddDeviceDataManager

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKAddDeviceDataManager销毁");
    [kNotificationCenterSington removeObserver:self name:MKNetworkStatusChangedNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedHeartBeatNotification object:nil];
    [kNotificationCenterSington removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (instancetype)init{
    if (self = [super init]) {
        //当前网络状态发生改变的通知
        [kNotificationCenterSington addObserver:self
                                       selector:@selector(networkStatusChanged)
                                           name:MKNetworkStatusChangedNotification
                                         object:nil];
    }
    return self;
}

+ (MKAddDeviceDataManager *)addDeviceManager{
    return [[self alloc] init];
}

#pragma mark - MKConnectViewConfirmDelegate
- (void)confirmButtonActionWithView:(UIView *)view returnData:(id)returnData{
    if (!view || ![view isKindOfClass:[UIView class]]) {
        return;
    }
    if (view == self.viewList[0]) {
        //MKConnectDeviceView
        [MKAddDeviceCenter gotoSystemWifiPage];
        return;
    }
    if (view == self.viewList[2]) {
        //MKConnectDeviceWifiView
        if (!ValidDict(returnData)) {
            return;
        }
        self.wifiSSID = returnData[@"ssid"];
        self.password = returnData[@"password"];
        [self connectSensor];
        return;
    }
}

- (void)cancelButtonActionWithView:(UIView *)view{
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    self.completeBlock = nil;
}

#pragma mark - MKWorkModeSelectDelegate
- (void)workModeSelected:(BOOL)isGPRSMode{
    self.isGPRSMode = isGPRSMode;
    if (isGPRSMode) {
        //用户选择了GPRS
        [self showConnectViewWithIndex:0];
        //直接开始连接设备
        [self connectSensor];
        return;
    }
    //用户选择了wifi
    [self showConnectViewWithIndex:2];
}

#pragma mark - event method

#pragma mark - notification
- (void)networkStatusChanged{
    if (![self needProcessNetworkChanged]) {
        //如果三个alert页面都没有加载到window，则不需要管网络状态改变通知
        return;
    }
    MKConnectDeviceProgressView *progressView = [self.viewList lastObject];
    if ([progressView isShow]) {
        //正在走连接进度流程，直接返回，
        return;
    }
    if (![MKDeviceModel currentWifiIsCorrect]) {
        //需要引导用户去连接smart plug
        [self showConnectViewWithIndex:0];
        return;
    }
    //如果是目标wifi，则让用户选择用哪种模式
    [self showConnectViewWithIndex:1];
}

- (void)receiveDeviceTopicData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic)
        || self.connectTimeout
        || ![deviceDic[@"mac"] isEqualToString:self.deviceDic[@"device_mac"]]) {
        return;
    }
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedHeartBeatNotification object:nil];
    //当前设备已经连上mqtt服务器了
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
        self.receiveTimerCount = 0;
        self.connectTimeout = NO;
    }
    MKConnectDeviceProgressView *progressView = [self.viewList lastObject];
    [progressView setProgress:1.f duration:0.2];
    [self performSelector:@selector(saveDeviceToLocal) withObject:nil afterDelay:0.5];
}

#pragma mark - public method

/**
 是否需要处理网络状态改变通知,如果四个alert页面都没有加载到window，则不需要管网络状态改变通知

 @return YES:需要处理，NO:不需要处理
 */
- (BOOL)needProcessNetworkChanged{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        if ([view isShow]) {
            return YES;
        }
    }
    return NO;
}

- (void)startConfigProcessWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    WS(weakSelf);
    [self connectProgressWithCompleteBlock:^(NSError *error, BOOL success, MKDeviceModel *deviceModel) {
        if (completeBlock) {
            completeBlock(error,success,deviceModel);
        }
        weakSelf.completeBlock = nil;
    }];
}

#pragma mark -
- (void)connectProgressWithCompleteBlock:(void (^)(NSError *error, BOOL success, MKDeviceModel *deviceModel))completeBlock{
    self.completeBlock = nil;
    self.completeBlock = completeBlock;
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedHeartBeatNotification object:nil];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(networkStatusChanged)
                                       name:UIApplicationDidBecomeActiveNotification
                                     object:nil];
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    [self.viewList removeAllObjects];
    [self loadViewList];
    if (![MKDeviceModel currentWifiIsCorrect]) {
        //需要引导用户去连接smart plug
        [self showConnectViewWithIndex:0];
        return;
    }
    [self showConnectViewWithIndex:1];
}

#pragma mark - SDK
- (void)connectSensor{
    //如果是rgps类型，在引导用户连接设备页面显示，如果是wifi类型则在输入wifi信息页面显示
    UIView *tempView = (self.isGPRSMode ? self.viewList[0] : self.viewList[2]);
    if (![MKDeviceModel currentWifiIsCorrect]) {
        [tempView showCentralToast:@"Please connect smart sensor"];
        return;
    }
    [[MKHudManager share] showHUDWithTitle:@"Setting..." inView:tempView isPenetration:NO];
    WS(weakSelf);
    sensorWorkMode mode = (self.isGPRSMode ? sensorWorkInGPRSMode : sensorWorkInWIFIMode);
    [[MKSmartPlugConnectManager sharedInstance] configDevice:mode wifiSSID:self.wifiSSID password:self.password sucBlock:^(NSDictionary *deviceInfo) {
        [[MKHudManager share] hide];
        weakSelf.deviceDic = nil;
        weakSelf.deviceDic = [NSMutableDictionary dictionaryWithDictionary:deviceInfo];
        [weakSelf connectMQTTServer];
    } failedBlock:^(NSError *error) {
        [[MKHudManager share] hide];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
        [weakSelf dismisAllAlertView];
    }];
}

#pragma mark - private method
- (void)connectMQTTServer{
    //开始连接mqtt服务器
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updateModel:self.deviceDic];
    [[MKMQTTServerManager sharedInstance] subscriptions:@[[model subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"#"]]];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receiveDeviceTopicData:)
                                       name:MKMQTTServerReceivedHeartBeatNotification
                                     object:nil];
    [kNotificationCenterSington removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [self startConnectTimer];
    [self showConnectViewWithIndex:(self.viewList.count - 1)];
}

- (void)startConnectTimer{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.receiveTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    self.receiveTimerCount = 0;
    self.connectTimeout = NO;
    dispatch_source_set_timer(self.receiveTimer, dispatch_walltime(NULL, 0), 1 * NSEC_PER_SEC, 0);
    WS(weakSelf);
    dispatch_source_set_event_handler(self.receiveTimer, ^{
        if (weakSelf.receiveTimerCount >= 90.f) {
            //接受数据超时
            [weakSelf connectFailed];
            return ;
        }
        weakSelf.receiveTimerCount ++;
    });
    dispatch_resume(self.receiveTimer);
}

- (void)connectFailed{
    self.receiveTimerCount = 0;
    self.connectTimeout = YES;
    if (self.receiveTimer) {
        dispatch_cancel(self.receiveTimer);
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismisAllAlertView];
        NSError *error = [[NSError alloc] initWithDomain:@"addDeviceDataManager" code:-999 userInfo:@{@"errorInfo":@"Connect failed"}];
        if (self.completeBlock) {
            self.completeBlock(error, NO, nil);
        }
        [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedHeartBeatNotification object:nil];
    });
}

- (void)saveDeviceToLocal{
    MKDeviceModel *dataModel = [[MKDeviceModel alloc] init];
    [dataModel updateModel:self.deviceDic];
    dataModel.local_name = self.deviceDic[@"device_name"];
    WS(weakSelf);
    [MKDeviceDataBaseManager insertDeviceList:@[dataModel] sucBlock:^{
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(nil, YES, dataModel);
        }
    } failedBlock:^(NSError *error) {
        [weakSelf dismisAllAlertView];
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(error, NO, nil);
        }
    }];
}

#pragma mark - alertView

- (void)showConnectViewWithIndex:(NSInteger)index{
    for (NSInteger i = 0; i < self.viewList.count; i ++) {
        id <MKConnectViewProtocol>view = self.viewList[i];
        if (i == index) {
            [view showConnectAlertView];
            if (index == self.viewList.count - 1) {
                MKConnectDeviceProgressView *progressView = (MKConnectDeviceProgressView *)view;
                [progressView setProgress:0.90 duration:90.f];
            }
        }else{
            [view dismiss];
        }
    }
}

- (void)dismisAllAlertView{
    for (id <MKConnectViewProtocol>view in self.viewList) {
        [view dismiss];
    }
}

- (void)loadViewList{
    MKConnectDeviceView *connectDeviceView = [[MKConnectDeviceView alloc] init];
    connectDeviceView.delegate = self;
    MKWorkModeView *modeView = [[MKWorkModeView alloc] init];
    modeView.delegate = self;
    MKConnectDeviceWifiView *wifiView = [[MKConnectDeviceWifiView alloc] init];
    wifiView.delegate = self;
    MKConnectDeviceProgressView *progressView = [[MKConnectDeviceProgressView alloc] init];
    progressView.delegate = self;
    [self.viewList addObject:connectDeviceView];
    [self.viewList addObject:modeView];
    [self.viewList addObject:wifiView];
    [self.viewList addObject:progressView];
}

#pragma mark - setter & getter
- (NSMutableArray *)viewList{
    if (!_viewList) {
        _viewList = [NSMutableArray arrayWithCapacity:3];
    }
    return _viewList;
}

@end
