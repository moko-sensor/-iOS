
/**
 智能插座状态

 */
typedef NS_ENUM(NSInteger, MKSmartPlugState) {
    MKSmartPlugOffline,             //离线状态
    MKSmartPlugOnline,              //在线
};

/**
 智能面板状态
 */
typedef NS_ENUM(NSInteger, MKSmartSwichState) {
    MKSmartSwichOffline,
    MKSmartSwichOnline,             //只有在线和离线两种状态
};

typedef NS_ENUM(NSInteger, deviceModelTopicType) {
    deviceModelTopicDeviceType,             //设备发布数据的主题
    deviceModelTopicAppType,                //APP发布数据的主题
};

@class MKDeviceModel;
/**
 设备在线状态发生改变
 */
@protocol MKDeviceModelDelegate <NSObject>

@optional
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel;

@end

@protocol MKDeviceModelProtocol <NSObject>

/**
 是否处于离线状态
 */
@property (nonatomic, assign, readonly)BOOL offline;

- (void)updatePropertyWithModel:(MKDeviceModel *)model;

/**
 设备列表页面的状态监控
 */
- (void)startStateMonitoringTimer;

/**
 接收到开关状态的时候，需要清除离线状态计数
 */
- (void)resetTimerCounter;

/**
 取消定时器
 */
- (void)cancel;

@end
