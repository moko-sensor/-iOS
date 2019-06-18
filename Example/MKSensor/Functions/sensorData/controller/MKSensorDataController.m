//
//  MKSensorDataController.m
//  MKSensor
//
//  Created by aa on 2019/1/15.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKSensorDataController.h"
#import "MKBaseTableView.h"
#import "MKSensorDataCell.h"
#import "MKSensorDataModel.h"
#import "MKDeviceInfoController.h"

@interface MKSensorDataController ()<UITableViewDelegate, UITableViewDataSource, MKDeviceModelDelegate>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)NSMutableDictionary *dataDic;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKSensorDataController

#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKSensorDataController销毁");
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"sensor_data"];
    [[MKMQTTServerManager sharedInstance] unsubscriptions:@[topic]];
    [kNotificationCenterSington removeObserver:self name:MKMQTTServerReceivedSensorDataNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.rightButton setImage:LOADIMAGE(@"configPlugPage_moreIcon", @"png") forState:UIControlStateNormal];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self setupTableViewData];
    NSString *topic = [self.deviceModel subscribeTopicInfoWithType:deviceModelTopicDeviceType function:@"sensor_data"];
    [[MKMQTTServerManager sharedInstance] subscriptions:@[topic]];
    [[MKHudManager share] showHUDWithTitle:@"Loading..." inView:self.view isPenetration:NO];
    [kNotificationCenterSington addObserver:self
                                   selector:@selector(receivedSensorData:)
                                       name:MKMQTTServerReceivedSensorDataNotification
                                     object:nil];
    self.deviceModel.delegate = self;
    // Do any additional setup after loading the view.
}

#pragma mark - super method

- (NSString *)defaultTitle{
    return @"Sensor Data";
}

- (void)rightButtonMethod{
    MKDeviceInfoController *vc = [[MKDeviceInfoController alloc] init];
    MKDeviceModel *model = [[MKDeviceModel alloc] init];
    [model updatePropertyWithModel:self.deviceModel];
    vc.deviceModel = model;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44.f;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKSensorDataCell *cell = [MKSensorDataCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - MKDeviceModelDelegate
- (void)deviceModelStateChanged:(MKDeviceModel *)deviceModel{
    self.deviceModel.sensorState = deviceModel.sensorState;
}

#pragma mark - Notification
- (void)receivedSensorData:(NSNotification *)note{
    NSDictionary *deviceDic = note.userInfo[@"userInfo"];
    if (!ValidDict(deviceDic) || ![deviceDic[@"mac"] isEqualToString:self.deviceModel.device_mac]) {
        return;
    }
    self.deviceModel.sensorState = MKSmartPlugOnline;
    [self updateSensorData:deviceDic];
}

#pragma mark - private method
- (NSString *)fetchValueStringWithNumber:(NSNumber *)number{
    if (!ValidNum(number)) {
        return @"";
    }
    return [NSString stringWithFormat:@"%ld",(long)[number integerValue]];
}
- (void)updateSensorData:(NSDictionary *)dic{
    [[MKHudManager share] hide];
    if (!ValidDict(dic)) {
        return;
    }
    if (ValidNum(dic[@"env_temp"])) {
        MKSensorDataModel *tempModel = self.dataDic[@"env_temp"];
        tempModel.isInvalidData = [self isInvalidData:dic[@"env_temp"]];
        CGFloat tempValue = [dic[@"env_temp"] integerValue] * 0.1;
        tempModel.value = [[NSString stringWithFormat:@"%.1f",tempValue] stringByAppendingString:@"℃"];
    }
    if (ValidNum(dic[@"humidity"])) {
        MKSensorDataModel *humiModel = self.dataDic[@"humidity"];
        humiModel.isInvalidData = [self isInvalidData:dic[@"humidity"]];
        CGFloat humiValue = [dic[@"humidity"] integerValue] * 0.1;
        humiModel.value = [[NSString stringWithFormat:@"%.1f",humiValue] stringByAppendingString:@"%RH"];
    }
    if (ValidNum(dic[@"NH3"])) {
        MKSensorDataModel *NHModel = self.dataDic[@"NH3"];
        NHModel.isInvalidData = [self isInvalidData:dic[@"NH3"]];
        NHModel.value = [[self fetchValueStringWithNumber:dic[@"NH3"]] stringByAppendingString:@"ppm"];
    }
    if (ValidNum(dic[@"CO2"])) {
        MKSensorDataModel *coModel = self.dataDic[@"CO2"];
        coModel.isInvalidData = [self isInvalidData:dic[@"CO2"]];
        coModel.value = [[self fetchValueStringWithNumber:dic[@"CO2"]] stringByAppendingString:@"ppm"];
    }
    if (ValidNum(dic[@"illumination"])) {
        MKSensorDataModel *illModel = self.dataDic[@"illumination"];
        illModel.isInvalidData = [self isInvalidData:dic[@"illumination"]];
        illModel.value = [[self fetchValueStringWithNumber:dic[@"illumination"]] stringByAppendingString:@"LX"];
    }
    if (ValidNum(dic[@"PM2_5"])) {
        MKSensorDataModel *pmModel = self.dataDic[@"PM2_5"];
        pmModel.isInvalidData = [self isInvalidData:dic[@"PM2_5"]];
        pmModel.value = [[NSString stringWithFormat:@"%.2f",[dic[@"PM2_5"] floatValue]] stringByAppendingString:@"μg/m³"];
    }
    if (ValidNum(dic[@"VOC"])) {
        MKSensorDataModel *VOCModel = self.dataDic[@"VOC"];
        VOCModel.isInvalidData = [self isInvalidData:dic[@"VOC"]];
        VOCModel.value = [[self fetchValueStringWithNumber:dic[@"VOC"]] stringByAppendingString:@"ppm"];
    }
    if (ValidNum(dic[@"distance"])) {
        MKSensorDataModel *distanceModel = self.dataDic[@"distance"];
        distanceModel.isInvalidData = [self isInvalidData:dic[@"distance"]];
        distanceModel.value = [[self fetchValueStringWithNumber:dic[@"distance"]] stringByAppendingString:@"cm"];
    }
    if (ValidNum(dic[@"infra_red_temp"])) {
        MKSensorDataModel *redTempModel = self.dataDic[@"infra_red_temp"];
        redTempModel.isInvalidData = [self isInvalidData:dic[@"infra_red_temp"]];
        CGFloat temp = [dic[@"infra_red_temp"] floatValue];
        temp = temp * 0.1;
        redTempModel.value = [[NSString stringWithFormat:@"%.1f",temp] stringByAppendingString:@"℃"];
    }
    [self.tableView reloadData];
}

- (BOOL)isInvalidData:(NSNumber *)number {
    return ([number integerValue] == 65535 || [number integerValue] == 65534);
}

- (void)setupTableViewData{
    if (self.deviceModel.deviceTypeModel.env_temp) {
        MKSensorDataModel *tempModel = [[MKSensorDataModel alloc] init];
        tempModel.leftIconName = @"Temperature";
        tempModel.message = @"Temperature";
        tempModel.value = @"0℃";
        [self.dataList addObject:tempModel];
        [self.dataDic setObject:tempModel forKey:@"env_temp"];
    }
    if (self.deviceModel.deviceTypeModel.humidity) {
        MKSensorDataModel *humiModel = [[MKSensorDataModel alloc] init];
        humiModel.leftIconName = @"Humidity";
        humiModel.message = @"Humidity";
        humiModel.value = @"0.0%RH";
        [self.dataList addObject:humiModel];
        [self.dataDic setObject:humiModel forKey:@"humidity"];
    }
    if (self.deviceModel.deviceTypeModel.NH3) {
        MKSensorDataModel *NHModel = [[MKSensorDataModel alloc] init];
        NHModel.leftIconName = @"NH3";
        NHModel.message = @"NH3";
        NHModel.value = @"0 ppm";
        [self.dataList addObject:NHModel];
        [self.dataDic setObject:NHModel forKey:@"NH3"];
    }
    if (self.deviceModel.deviceTypeModel.CO2) {
        MKSensorDataModel *coModel = [[MKSensorDataModel alloc] init];
        coModel.leftIconName = @"CO2";
        coModel.message = @"CO2";
        coModel.value = @"0 ppm";
        [self.dataList addObject:coModel];
        [self.dataDic setObject:coModel forKey:@"CO2"];
    }
    if (self.deviceModel.deviceTypeModel.illumination) {
        MKSensorDataModel *illModel = [[MKSensorDataModel alloc] init];
        illModel.leftIconName = @"illumination";
        illModel.message = @"illumination";
        illModel.value = @"250LX";
        [self.dataList addObject:illModel];
        [self.dataDic setObject:illModel forKey:@"illumination"];
    }
    if (self.deviceModel.deviceTypeModel.PM2_5) {
        MKSensorDataModel *pmModel = [[MKSensorDataModel alloc] init];
        pmModel.leftIconName = @"PM2.5";
        pmModel.message = @"PM2.5";
        pmModel.value = @"0μg/m³";
        [self.dataList addObject:pmModel];
        [self.dataDic setObject:pmModel forKey:@"PM2_5"];
    }
    if (self.deviceModel.deviceTypeModel.VOC) {
        MKSensorDataModel *VOCModel = [[MKSensorDataModel alloc] init];
        VOCModel.leftIconName = @"VOC";
        VOCModel.message = @"VOC";
        VOCModel.value = @"0 ppm";
        [self.dataList addObject:VOCModel];
        [self.dataDic setObject:VOCModel forKey:@"VOC"];
    }
    if (self.deviceModel.deviceTypeModel.distance) {
        MKSensorDataModel *distanceModel = [[MKSensorDataModel alloc] init];
        distanceModel.leftIconName = @"LaserRanging";
        distanceModel.message = @"Laser Ranging";
        distanceModel.value = @"0 cm";
        [self.dataList addObject:distanceModel];
        [self.dataDic setObject:distanceModel forKey:@"distance"];
    }
    if (self.deviceModel.deviceTypeModel.infra_red_temp) {
        MKSensorDataModel *redTempModel = [[MKSensorDataModel alloc] init];
        redTempModel.leftIconName = @"LaserTemperature";
        redTempModel.message = @"Infrared temperature";
        redTempModel.value = @"0℃";
        [self.dataList addObject:redTempModel];
        [self.dataDic setObject:redTempModel forKey:@"infra_red_temp"];
    }
    [self.tableView reloadData];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

- (NSMutableDictionary *)dataDic {
    if (!_dataDic) {
        _dataDic = [NSMutableDictionary dictionary];
    }
    return _dataDic;
}

@end
