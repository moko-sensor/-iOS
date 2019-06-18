//
//  MKWorkModeView.m
//  MKSensor
//
//  Created by aa on 2019/1/10.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKWorkModeView.h"

static CGFloat const centerIconWidth = 105.f;
static CGFloat const centerIconHeight = 80.f;

@interface MKWorkModeView ()

@property (nonatomic, strong)UIView *titleView;

@property (nonatomic, strong)UILabel *msgLabel;

@property (nonatomic, strong)UIImageView *gprsIcon;

@property (nonatomic, strong)UIImageView *wifiIcon;

@property (nonatomic, strong)UIButton *doneButton;

@property (nonatomic, assign)BOOL isGPRSMode;

@end

@implementation MKWorkModeView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.frame = kAppWindow.bounds;
        [self setBackgroundColor:COLOR_WHITE_MACROS];
        self.isGPRSMode = YES;
        [self addSubview:self.titleView];
        [self addSubview:self.msgLabel];
        [self addSubview:self.gprsIcon];
        [self addSubview:self.wifiIcon];
        [self addSubview:self.doneButton];
    }
    return self;
}

#pragma mark - super method
- (void)layoutSubviews{
    [super layoutSubviews];
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(64.f);
    }];
    [self.msgLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.top.mas_equalTo(self.titleView.mas_bottom).mas_offset(50.f);
        make.height.mas_equalTo(MKFont(15.f).lineHeight);
    }];
    [self.gprsIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(centerIconWidth);
        make.top.mas_equalTo(self.msgLabel.mas_bottom).mas_offset(90.f);
        make.height.mas_equalTo(centerIconHeight);
    }];
    [self.wifiIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.width.mas_equalTo(centerIconWidth);
        make.top.mas_equalTo(self.gprsIcon.mas_bottom).mas_offset(50.f);
        make.height.mas_equalTo(centerIconHeight);
    }];
    [self.doneButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15.f);
        make.right.mas_equalTo(-15.f);
        make.bottom.mas_equalTo(-60.f);
        make.height.mas_equalTo(45.f);
    }];
}

#pragma mark - MKConnectViewProtocol
- (void)showConnectAlertView{
    [self dismiss];
    [kAppWindow addSubview:self];
}

- (void)dismiss{
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (BOOL)isShow{
    return (self.superview != nil);
}

#pragma mark - event method
- (void)doneButtonPressed{
    if ([self.delegate respondsToSelector:@selector(workModeSelected:)]) {
        [self.delegate workModeSelected:self.isGPRSMode];
    }
    [self dismiss];
}

- (void)gprsModeSelected{
    self.isGPRSMode = YES;
    [self reloadIcons];
}

- (void)wifiModeSelected{
    self.isGPRSMode = NO;
    [self reloadIcons];
}

#pragma mark - private method
- (void)reloadIcons{
    NSString *gprsIconName = (self.isGPRSMode ? @"GPRSSelectedIcon" : @"GPRSUnselectedIcon");
    self.gprsIcon.image = LOADIMAGE(gprsIconName, @"png");
    NSString *wifiIconName = (self.isGPRSMode ? @"WIFIUnselectedIcon" : @"WIFISelectedIcon");
    self.wifiIcon.image = LOADIMAGE(wifiIconName, @"png");
}

#pragma mark - setter & getter

- (UIView *)titleView{
    if (!_titleView) {
        _titleView = [[UIView alloc] init];
        _titleView.backgroundColor = NAVIGATION_BAR_COLOR;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = COLOR_WHITE_MACROS;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = MKFont(18.f);
        titleLabel.text = @"Select Work Mode";
        [_titleView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_titleView.mas_centerX);
            make.width.mas_equalTo(150.f);
            make.bottom.mas_equalTo(-5.f);
            make.height.mas_equalTo(MKFont(18.f).lineHeight);
        }];
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setImage:LOADIMAGE(@"navigation_back_button", @"png") forState:UIControlStateNormal];
        [backButton addTapAction:self selector:@selector(dismiss)];
        [_titleView addSubview:backButton];
        [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.width.mas_equalTo(50.f);
            make.bottom.mas_equalTo(-2.f);
            make.height.mas_equalTo(40.f);
        }];
    }
    return _titleView;
}

- (UILabel *)msgLabel{
    if (!_msgLabel) {
        _msgLabel = [[UILabel alloc] init];
        _msgLabel.textAlignment = NSTextAlignmentCenter;
        _msgLabel.textColor = NAVIGATION_BAR_COLOR;
        _msgLabel.font = MKFont(15.f);
        _msgLabel.text = @"Please select the device work mode";
    }
    return _msgLabel;
}

- (UIImageView *)gprsIcon{
    if (!_gprsIcon) {
        _gprsIcon = [[UIImageView alloc] init];
        _gprsIcon.image = LOADIMAGE(@"GPRSSelectedIcon", @"png");
        _gprsIcon.userInteractionEnabled = YES;
        [_gprsIcon addTapAction:self selector:@selector(gprsModeSelected)];
    }
    return _gprsIcon;
}

- (UIImageView *)wifiIcon{
    if (!_wifiIcon) {
        _wifiIcon = [[UIImageView alloc] init];
        _wifiIcon.image = LOADIMAGE(@"WIFIUnselectedIcon", @"png");
        _wifiIcon.userInteractionEnabled = YES;
        [_wifiIcon addTapAction:self selector:@selector(wifiModeSelected)];
    }
    return _wifiIcon;
}

- (UIButton *)doneButton{
    if (!_doneButton) {
        _doneButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@"Done"
                                                               target:self
                                                               action:@selector(doneButtonPressed)];
    }
    return _doneButton;
}

@end
