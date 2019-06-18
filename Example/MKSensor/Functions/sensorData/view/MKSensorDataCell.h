//
//  MKSensorDataCell.h
//  MKSensor
//
//  Created by aa on 2019/1/15.
//  Copyright © 2019 MK. All rights reserved.
//

#import "MKBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@class MKSensorDataModel;
@interface MKSensorDataCell : MKBaseCell

@property (nonatomic, strong)MKSensorDataModel *dataModel;

+ (MKSensorDataCell *)initCellWithTableView:(UITableView *)table;

@end

NS_ASSUME_NONNULL_END
