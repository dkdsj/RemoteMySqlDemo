//
//  OHMysqlHelper.m
//  RemoteMySqlDemo
//
//  Created by ZZ on 2019/10/21.
//  Copyright © 2019 ZZ. All rights reserved.
//

#import "OHMysqlHelper.h"
#import "OHMySQL.h"

@interface OHMysqlHelper ()<OHMySQLStoreCoordinatorProtocol>

@property (nonatomic, strong) OHMySQLStoreCoordinator *coordinator;
@property (nonatomic, strong) OHMySQLQueryContext *queryContext;
@property (nonatomic, strong) OHMySQLQueryRequest *query;

@end

@implementation OHMysqlHelper

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static OHMysqlHelper *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initData];
    }
    return self;
}

- (void)initData {
    NSString *host = @"rm-uf6eu4l47o69d6fhxso.mysql.rds.aliyuncs.com";
    NSString *userName = @"xbadmin";
    NSString *pwd = @"C6@UqHoR!TupxhPjdTWr";
    NSString *dbName = @"np2-rfidpackage";
    NSInteger port = 3306;
    
    OHMySQLUser *user = [[OHMySQLUser alloc] initWithUserName:userName
                                                     password:pwd
                                                   serverName:host
                                                       dbName:dbName
                                                         port:port
                                                       socket:nil];
    _coordinator = [[OHMySQLStoreCoordinator alloc] initWithUser:user];
    _coordinator.delegate = self;
    
    _queryContext = [OHMySQLQueryContext new];
    _queryContext.storeCoordinator = _coordinator;
}

- (void)omhConnect {
    NSLog(@"开始连接数据库...");
    [_coordinator connect];
}

- (void)omhDisconnect {
    [_coordinator disconnect];
}


/**
 [OHMySQLQueryRequestFactory DELETE:tableName condition:[NSString stringWithFormat:@"%@='%@'", key, value]];
 */
- (NSString *)omhQueryTable:(NSString *)tableName condition:(NSString *)condition {
    if (!_coordinator.connected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:@"数据库连接失败" type:OHMysqlHelperTypeQuery];
        }
        return @"数据库连接失败";
    }
    
    _query = [OHMySQLQueryRequestFactory SELECT:tableName condition:condition];
    
    NSError *error = nil;
    NSArray *tasks = [_queryContext executeQueryRequestAndFetchResult:_query error:&error];
    if (tasks != nil) {
        NSLog(@"%@",tasks);
        
        for (NSDictionary *task in tasks) {
            NSString *result = [self convertToJsonData:task];
            if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperResponMsg:type:)]) {
                [self.delegate ohMysqlHelperResponMsg:result type:OHMysqlHelperTypeQuery];
            }
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:[NSString stringWithFormat:@"查询err:%@",  error.description] type:OHMysqlHelperTypeQuery];
        }
    }
    
    return nil;
}

- (NSString *)omhDeleteTable:(NSString *)tableName condition:(NSString *)condition {
    if (!_coordinator.connected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:@"数据库连接失败" type:OHMysqlHelperTypeDelete];
        }
        return @"数据库连接失败";
    }
    
    return nil;
}


/**
 NSDictionary *insetDic = @{@"masterid":@"masterid11112223",
                            @"actual_price":@"10009"};
 [OHMySQLQueryRequestFactory INSERT:tableName set:insetDic];
 */
- (NSString *)omhAddTable:(NSString *)tableName inset:(NSDictionary *)inset {
    if (!_coordinator.connected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:@"数据库连接失败" type:OHMysqlHelperTypeAdd];
        }
        return @"数据库连接失败";
    }
    
    _query = [OHMySQLQueryRequestFactory INSERT:tableName set:inset];
    
    NSError *error = nil;
    [_queryContext executeQueryRequestAndFetchResult:_query error:&error];
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:[NSString stringWithFormat:@"添加err:%@",  error.description] type:OHMysqlHelperTypeAdd];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperResponMsg:type:)]) {
            NSString *msg = [NSString stringWithFormat:@"添加成功%@", inset];
            [self.delegate ohMysqlHelperResponMsg:msg type:OHMysqlHelperTypeAdd];
        }
    }
    
    return nil;
}


/**
 NSString *tableName = @"rfidpackage_tb_ordermaster";
 NSString *key = @"masterid";
 NSString *value = @"masid012345678";
 NSDictionary *updateDic = @{@"actual_price":@"1089"};
 */
- (NSString *)omhUpdateTable:(NSString *)tableName inset:(NSDictionary *)inset condition:(NSString *)condition {
    if (!_coordinator.connected) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:@"数据库连接失败" type:OHMysqlHelperTypeUpdate];
        }
        return @"数据库连接失败";
    }
    
    _query = [OHMySQLQueryRequestFactory UPDATE:tableName set:inset condition:condition];
    
    NSError *error = nil;
    [_queryContext executeQueryRequestAndFetchResult:_query error:&error];
    if (error) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
            [self.delegate ohMysqlHelperErrorMsg:[NSString stringWithFormat:@"更新err:%@",  error.description] type:OHMysqlHelperTypeUpdate];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperResponMsg:type:)]) {
            NSString *msg = [NSString stringWithFormat:@"更新成功%@", inset];
            [self.delegate ohMysqlHelperResponMsg:msg type:OHMysqlHelperTypeUpdate];
        }
    }
    
    return nil;
}


- (NSString *)convertToJsonData:(NSDictionary *)dict {
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    //    NSRange range = {0,jsonString.length};
    //    //去掉字符串中的空格
    //    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    //去掉字符串中的换行符
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
    
    return mutStr;
}

- (NSDictionary *)convertToDictionary:(NSString *)jsonStr {
    NSData *data = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *tempDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    return tempDic;
}


#pragma mark - (void)oHMySQLStoreCoordinatorConnectFailed

- (void)oHMySQLStoreCoordinatorConnectFailed {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ohMysqlHelperErrorMsg:type:)]) {
        [self.delegate ohMysqlHelperErrorMsg:@"数据库连接失败" type:OHMysqlHelperTypeConnect];
    }
}


@end
