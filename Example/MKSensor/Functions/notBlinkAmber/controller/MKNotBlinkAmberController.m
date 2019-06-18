//
//  MKNotBlinkAmberController.m
//  MKSmartPlug
//
//  Created by aa on 2018/6/4.
//  Copyright © 2018年 MK. All rights reserved.
//

#import "MKNotBlinkAmberController.h"
#import "MKNotBlinkAmberCell.h"
#import "MKNotBlinkAmberModel.h"
#import "MKBaseTableView.h"

@interface MKNotBlinkAmberController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong)MKBaseTableView *tableView;

@property (nonatomic, strong)UIButton *blinkButton;

@property (nonatomic, strong)NSMutableArray *dataList;

@end

@implementation MKNotBlinkAmberController
#pragma mark - life circle
- (void)dealloc{
    NSLog(@"MKNotBlinkAmberController销毁");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self getInitDatas];
    // Do any additional setup after loading the view.
}

#pragma mark - 父类方法
- (NSString *)defaultTitle{
    return @"Operation Steps";
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 225.f;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MKNotBlinkAmberCell *cell = [MKNotBlinkAmberCell initCellWithTableView:tableView];
    cell.dataModel = self.dataList[indexPath.row];
    return cell;
}

#pragma mark - event method
- (void)blinkButtonPressed{
    [self leftButtonMethod];
    if (self.blinkButtonPressedBlock) {
        self.blinkButtonPressedBlock();
    }
}

#pragma mark - loadSubViews

- (void)getInitDatas{
     NSDictionary *params = [[MKAddDeviceCenter sharedInstance] fecthNotBlinkParams];
    NSArray *sourceList = params[@"sourceList"];
    for (NSDictionary *dic in sourceList) {
        MKNotBlinkAmberModel *stepModel = [MKNotBlinkAmberModel modelWithJSON:dic];
        if (stepModel) {
            [self.dataList addObject:stepModel];
        }
    }
    [self.tableView reloadData];
    [self.blinkButton setTitle:params[@"blinkButtonTitle"] forState:UIControlStateNormal];
}

- (void)loadSubViews{
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

#pragma mark - setter & getter
- (MKBaseTableView *)tableView{
    if (!_tableView) {
        _tableView = [[MKBaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.tableFooterView = [self tableFooter];
    }
    return _tableView;
}

- (UIButton *)blinkButton{
    if (!_blinkButton) {
        _blinkButton = [MKCommonlyUIHelper commonBottomButtonWithTitle:@""
                                                                target:self
                                                                action:@selector(blinkButtonPressed)];
    }
    return _blinkButton;
}

- (UIView *)tableFooter{
    UIView *tableFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150.f)];
    tableFooter.backgroundColor = UIColorFromRGB(0xf2f2f2);
    
    [tableFooter addSubview:self.blinkButton];
    [self.blinkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(58.f);
        make.width.mas_equalTo(kScreenWidth - 2 * 58);
        make.bottom.mas_equalTo(-50.f);
        make.height.mas_equalTo(50.f);
    }];
    return tableFooter;
}

- (NSMutableArray *)dataList{
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
