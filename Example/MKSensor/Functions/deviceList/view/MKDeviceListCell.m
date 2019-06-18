//
//  MKDeviceListCell.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/11.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKDeviceListCell.h"

static NSString *const MKDeviceListCellIdenty = @"MKDeviceListCellIdenty";

static CGFloat const deviceIconWidth = 50.f;
static CGFloat const deviceIconHeight = 50.f;
static CGFloat const nextIconWidth = 8.f;
static CGFloat const nextIconHeight = 15.f;

@interface MKDeviceListCell()

@property (nonatomic, strong)UIImageView *deviceIcon;

@property (nonatomic, strong)UILabel *deviceNameLabel;

@property (nonatomic, strong)UILabel *deviceStateLabel;

@property (nonatomic, strong)UIImageView *nextIcon;

//@property (nonatomic, strong)UIButton *stateButton;

@end

@implementation MKDeviceListCell

+ (MKDeviceListCell *)initCellWithTableView:(UITableView *)tableView{
    MKDeviceListCell *cell = [tableView dequeueReusableCellWithIdentifier:MKDeviceListCellIdenty];
    if (!cell) {
        cell = [[MKDeviceListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKDeviceListCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.deviceIcon];
        [self.contentView addSubview:self.deviceNameLabel];
        [self.contentView addSubview:self.deviceStateLabel];
        [self.contentView addSubview:self.nextIcon];
//        [self.contentView addSubview:self.stateButton];
    }
    return self;
}

#pragma mark - 父类方法
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.deviceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(deviceIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(deviceIconHeight);
    }];
    CGSize nameSize = [NSString sizeWithText:self.deviceNameLabel.text
                                     andFont:self.deviceNameLabel.font
                                  andMaxSize:CGSizeMake(MAXFLOAT, MKFont(13.f).lineHeight)];
    CGFloat width = MIN(nameSize.width, kScreenWidth - 5 * 15.f - deviceIconWidth - nextIconWidth);
    [self.deviceNameLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.deviceIcon.mas_right).mas_offset(15.f);
        make.width.mas_equalTo(width);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(13.f).lineHeight);
    }];
    [self.nextIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-15.f);
        make.width.mas_equalTo(nextIconWidth);
        make.centerY.mas_equalTo(self.deviceNameLabel.mas_centerY);
        make.height.mas_equalTo(nextIconHeight);
    }];
    [self.deviceStateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.nextIcon.mas_left).mas_offset(-5.f);
        make.width.mas_equalTo(60.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
//    [self.stateButton mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.mas_equalTo(-15.f);
//        make.width.mas_equalTo(switchWidth);
//        make.centerY.mas_equalTo(self.contentView.mas_centerY);
//        make.height.mas_equalTo(switchHeight);
//    }];
}

#pragma mark - event method
- (void)stateChanged{
//    if ([self.delegate respondsToSelector:@selector(deviceSwitchStateChanged:isOn:)]) {
//        [self.delegate deviceSwitchStateChanged:self.dataModel isOn:!self.stateButton.isSelected];
//    }
}

#pragma mark - public method
- (void)setDataModel:(MKDeviceModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    if (ValidStr(_dataModel.local_name)) {
        self.deviceNameLabel.text = _dataModel.local_name;
    }
    if (_dataModel.sensorState == MKSmartPlugOnline) {
        //在线
        self.deviceIcon.image = LOADIMAGE(@"device_sensorOnlineIcon", @"png");
        self.deviceNameLabel.textColor = NAVIGATION_BAR_COLOR;
        self.deviceStateLabel.textColor = NAVIGATION_BAR_COLOR;
        self.deviceStateLabel.text = @"Online";
        self.nextIcon.image = LOADIMAGE(@"MKSmartPlugRightNextBlueIcon", @"png");
        return;
    }
    //离线
    self.deviceIcon.image = LOADIMAGE(@"device_sensorOfflineIcon", @"png");
    self.deviceNameLabel.textColor = UIColorFromRGB(0xcccccc);
    self.deviceStateLabel.textColor = UIColorFromRGB(0xcccccc);
    self.deviceStateLabel.text = @"Offline";
    self.nextIcon.image = LOADIMAGE(@"MKSmartPlugRightNextIcon", @"png");
    [self setNeedsLayout];
}

#pragma mark - setter & getter
- (UIImageView *)deviceIcon{
    if (!_deviceIcon) {
        _deviceIcon = [[UIImageView alloc] init];
        _deviceIcon.image = LOADIMAGE(@"device_sensorOfflineIcon", @"png");
    }
    return _deviceIcon;
}

- (UILabel *)deviceNameLabel{
    if (!_deviceNameLabel) {
        _deviceNameLabel = [[UILabel alloc] init];
        _deviceNameLabel.textColor = UIColorFromRGB(0xcccccc);
        _deviceNameLabel.textAlignment = NSTextAlignmentLeft;
        _deviceNameLabel.font = MKFont(15.f);
    }
    return _deviceNameLabel;
}

- (UILabel *)deviceStateLabel{
    if (!_deviceStateLabel) {
        _deviceStateLabel = [[UILabel alloc] init];
        _deviceStateLabel.textColor = UIColorFromRGB(0xcccccc);
        _deviceStateLabel.textAlignment = NSTextAlignmentLeft;
        _deviceStateLabel.font = MKFont(13.f);
    }
    return _deviceStateLabel;
}

- (UIImageView *)nextIcon{
    if (!_nextIcon) {
        _nextIcon = [[UIImageView alloc] init];
        _nextIcon.image = LOADIMAGE(@"MKSmartPlugRightNextIcon", @"png");
    }
    return _nextIcon;
}

@end
