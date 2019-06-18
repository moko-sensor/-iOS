//
//  MKSensorDataCell.m
//  MKSensor
//
//  Created by aa on 2019/1/15.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKSensorDataCell.h"
#import "MKSensorDataModel.h"

static CGFloat const leftIconWidth = 20.f;
static CGFloat const leftIconHeight = 20.f;

static NSString *const MKSensorDataCellIdenty = @"MKSensorDataCellIdenty";

@interface MKSensorDataCell ()

@property (nonatomic, strong)UIImageView *leftIcon;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UILabel *valueLabel;

@end

@implementation MKSensorDataCell

+ (MKSensorDataCell *)initCellWithTableView:(UITableView *)table{
    MKSensorDataCell *cell = [table dequeueReusableCellWithIdentifier:MKSensorDataCellIdenty];
    if (!cell) {
        cell = [[MKSensorDataCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MKSensorDataCellIdenty];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self.contentView addSubview:self.leftIcon];
        [self.contentView addSubview:self.msgLabel];
        [self.contentView addSubview:self.valueLabel];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.leftIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.width.mas_equalTo(leftIconWidth);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(leftIconHeight);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftIcon.mas_right).mas_offset(10.f);
        make.right.mas_equalTo(self.contentView.mas_centerX).mas_offset(5.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView.mas_centerX).mas_offset(-5.f);
        make.right.mas_equalTo(-15.f);
        make.centerY.mas_equalTo(self.contentView.mas_centerY);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
}

#pragma mark - public method
- (void)setDataModel:(MKSensorDataModel *)dataModel{
    _dataModel = nil;
    _dataModel = dataModel;
    if (!_dataModel) {
        return;
    }
    self.leftIcon.image = LOADIMAGE(_dataModel.leftIconName, @"png");
    self.msgLabel.text = _dataModel.message;
    if (_dataModel.isInvalidData) {
        self.valueLabel.textColor = [UIColor redColor];
        self.valueLabel.text = @"-";
    }else {
        self.valueLabel.textColor = UIColorFromRGB(0x808080);
        self.valueLabel.text = _dataModel.value;
    }
}

#pragma mark - setter & getter
- (UIImageView *)leftIcon{
    if (!_leftIcon) {
        _leftIcon = [[UIImageView alloc] init];
    }
    return _leftIcon;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textColor = DEFAULT_TEXT_COLOR;
        _msgLabel.textAlignment = NSTextAlignmentLeft;
        _msgLabel.font = MKFont(15.f);
    }
    return _msgLabel;
}

- (UILabel *)valueLabel{
    if (!_valueLabel) {
        _valueLabel = [[UILabel alloc] init];
        _valueLabel.textColor = UIColorFromRGB(0x808080);
        _valueLabel.textAlignment = NSTextAlignmentRight;
        _valueLabel.font = MKFont(15.f);
    }
    return _valueLabel;
}

@end
