//
//  MKMQTTServerTaskOperation.h
//  MKSmartPlug
//
//  Created by aa on 2018/6/23.
//  Copyright © 2018年 MK. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MKMQTTServerOperationProtocol <NSObject>

- (void)sendMessageSuccess:(NSInteger)operationID;

@end

@interface MKMQTTServerTaskOperation : NSOperation<MKMQTTServerOperationProtocol>

/**
 Initialize the communication thread
 
 @param operationID The task ID of the current thread
 @param completeBlock Data communication completion callback
 @return operation
 */
- (instancetype)initOperationWithID:(NSInteger)operationID
                      completeBlock:(void (^)(NSError *error, NSInteger operationID))completeBlock;

@end
