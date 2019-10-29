//
//  OHMysqlHelper.h
//  RemoteMySqlDemo
//
//  Created by ZZ on 2019/10/21.
//  Copyright © 2019 ZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    OHMysqlHelperTypeConnect,
    OHMysqlHelperTypeAdd,
    OHMysqlHelperTypeDelete,
    OHMysqlHelperTypeUpdate,
    OHMysqlHelperTypeQuery,
} OHMysqlHelperType;

@protocol OHMysqlHelperProtocol <NSObject>

@optional
- (void)ohMysqlHelperErrorMsg:(NSString *)msg type:(OHMysqlHelperType)type;
- (void)ohMysqlHelperResponMsg:(NSString *)msg type:(OHMysqlHelperType)type;


@end

@interface OHMysqlHelper : NSObject

@property (nonatomic, weak) id<OHMysqlHelperProtocol> delegate;

+ (instancetype)sharedInstance;

- (void)omhConnect;
- (void)omhDisconnect;

/**
 [OHMySQLQueryRequestFactory DELETE:tableName condition:[NSString stringWithFormat:@"%@='%@'", key, value]];
 */
- (NSString *)omhQueryTable:(NSString *)tableName condition:(NSString *)condition;
- (NSString *)omhDeleteTable:(NSString *)tableName condition:(NSString *)condition;

/**
 NSDictionary *insetDic = @{@"masterid":@"masterid11112223",
                            @"actual_price":@"10009"};
 [OHMySQLQueryRequestFactory INSERT:tableName set:insetDic];
 */
- (NSString *)omhAddTable:(NSString *)tableName inset:(NSDictionary *)inset;

/**
 NSString *tableName = @"rfidpackage_tb_ordermaster";
 NSString *key = @"masterid";
 NSString *value = @"masid012345678";
 NSDictionary *updateDic = @{@"actual_price":@"1089"};
 */
- (NSString *)omhUpdateTable:(NSString *)tableName inset:(NSDictionary *)inset condition:(NSString *)condition;

@end

NS_ASSUME_NONNULL_END
