//
//  ViewController.m
//  RemoteMySqlDemo
//
//  Created by ZZ on 2019/10/18.
//  Copyright © 2019 ZZ. All rights reserved.
//

#import "ViewController.h"
#import <OHMySQL.h>
#import "OHMysqlHelper.h"

@interface ViewController ()<OHMysqlHelperProtocol> {
    OHMySQLStoreCoordinator *coordinator;
    OHMySQLQueryContext *queryContext;
    OHMySQLQueryRequest *query;
}
@property (weak, nonatomic) IBOutlet UITextView *tvRecord;

@property (nonatomic, strong) OHMysqlHelper *omh;

@end

@implementation ViewController

- (void)demo {
    NSArray *tasks = [NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/zz/Projects/code/OCPj/RemoteMySqlDemo/tasks.json"];
    NSLog(@"%@", tasks);
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/zz/Projects/code/OCPj/RemoteMySqlDemo/tasks1.json"];
    NSArray *tasks1 = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:nil];
    
    tasks = @[@{@"a":@"123", @"b":@"123"}];
    
    BOOL rst = [NSKeyedArchiver archiveRootObject:tasks toFile:@"/Users/zz/Projects/code/OCPj/RemoteMySqlDemo/tasks.json"];
    data = [NSKeyedArchiver archivedDataWithRootObject:tasks requiringSecureCoding:YES error:nil];
    rst = [data writeToFile:@"/Users/zz/Projects/code/OCPj/RemoteMySqlDemo/tasks1.json" atomically:YES];
    if (rst) {
        NSLog(@"write ok");
    } else {
        NSLog(@"write failed");
    }
}

- (void)baseAlertWithTitle:(NSString *)title msg:(NSString *)msg {
    UIAlertController *alter = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alter addAction:action];
    [self presentViewController:alter animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alter dismissViewControllerAnimated:YES completion:nil];
    });
}
- (void)baseAlertWithTitle:(NSString *)title {
    [self baseAlertWithTitle:title msg:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _omh = [OHMysqlHelper sharedInstance];
    _omh.delegate = self;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [_omh omhConnect];
}

- (void)connectDB {
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
    coordinator = [[OHMySQLStoreCoordinator alloc] initWithUser:user];
    [coordinator connect];
    
    queryContext = [OHMySQLQueryContext new];
    queryContext.storeCoordinator = coordinator;
}

- (IBAction)connectToMysql:(UIBarButtonItem *)sender {
//    [self connectDB];
    
    [_omh omhConnect];
}

- (IBAction)disconnectMysql:(UIBarButtonItem *)sender {
//    [coordinator disconnect];
    _tvRecord.text = @"";
}

/**
 masterid NP479638823953064200
 barcode  3942324958859050
 secret   295436
 id       289
 */
- (IBAction)handleQuery:(UIButton *)sender {
    NSString *rst = [_omh omhQueryTable:@"rfidpackage_tb_ordermaster" condition:@"barcode='4513215641321215'"];
    if (rst) {
        NSLog(@"%@", rst);
    }
    return;
    
    
    
    
    
    if (!coordinator.connected) {
        [self baseAlertWithTitle:@"没连接上db"];
        return;
    }
    
    _tvRecord.text = @"";
    
    NSString *tableName = @"rfidpackage_tb_ordermaster";
    NSString *key = @"barcode";
    NSString *value = @"4513215641321215";
    query = [OHMySQLQueryRequestFactory SELECT:tableName condition:[NSString stringWithFormat:@"%@='%@'", key, value]];
    
    NSError *error = nil;
    NSArray *tasks = [queryContext executeQueryRequestAndFetchResult:query error:&error];
    if (tasks != nil) {
        NSLog(@"%@",tasks);
        
        for (NSDictionary *task in tasks) {
            NSString *log = [self convertToJsonData:task];
            _tvRecord.text = [_tvRecord.text stringByAppendingString:log];
        }
    } else {
        NSLog(@"%@", error.description);
    }
}

- (IBAction)handleDelete:(UIButton *)sender {
    NSString *rst = [_omh omhDeleteTable:@"rfidpackage_tb_ordermaster" condition:@"masterid='masterid11112222'"];
    if (rst) {
        NSLog(@"%@", rst);
    }
    return;
    
    
    
    
    
    if (!coordinator.connected) {
        [self baseAlertWithTitle:@"没连接上db"];
        return;
    }
    
    NSString *tableName = @"rfidpackage_tb_ordermaster";
    NSString *key = @"masterid";
    NSString *value = @"masterid11112222";
    
    query = [OHMySQLQueryRequestFactory DELETE:tableName condition:[NSString stringWithFormat:@"%@='%@'", key, value]];
    
    NSError *error = nil;
    [queryContext executeQueryRequestAndFetchResult:query error:&error];
    if (error) {
        _tvRecord.text = error.description;
    } else {
        _tvRecord.text = [NSString stringWithFormat:@"删除%@成功", value];
    }
}

- (IBAction)handleAdd:(UIButton *)sender {
    NSString *rst = [_omh omhAddTable:@"rfidpackage_tb_ordermaster" inset:@{@"masterid":@"masterid11112223", @"actual_price":@"10009"}];
    if (rst) {
        NSLog(@"%@", rst);
    }
    return;
    
    
    
    
    
    if (!coordinator.connected) {
        [self baseAlertWithTitle:@"没连接上db"];
        return;
    }
    
    NSString *tableName = @"rfidpackage_tb_ordermaster";
    NSDictionary *insetDic = @{@"masterid":@"masterid11112223",
                               @"actual_price":@"10009"};
    query = [OHMySQLQueryRequestFactory INSERT:tableName set:insetDic];
    
    NSError *error = nil;
    [queryContext executeQueryRequestAndFetchResult:query error:&error];
    if (error) {
        _tvRecord.text = error.description;
    } else {
        _tvRecord.text = [NSString stringWithFormat:@"添加%@成功", insetDic[@"masterid"]];
    }
}

- (IBAction)handleUpdate:(UIButton *)sender {
    NSString *rst = [_omh omhUpdateTable:@"rfidpackage_tb_ordermaster" inset:@{@"actual_price":@"1089"} condition:@"masterid='masterid11112222'"];
    if (rst) {
        NSLog(@"%@", rst);
    }
    return;
    
    
    
    
    
    if (!coordinator.connected) {
        [self baseAlertWithTitle:@"没连接上db"];
        return;
    }
    
    NSString *tableName = @"rfidpackage_tb_ordermaster";
    NSString *key = @"masterid";
    NSString *value = @"masid012345678";
    NSDictionary *updateDic = @{@"actual_price":@"1089"};
    query = [OHMySQLQueryRequestFactory UPDATE:tableName set:updateDic condition:[NSString stringWithFormat:@"%@='%@'", key, value]];
    
    NSError *error = nil;
    [queryContext executeQueryRequestAndFetchResult:query error:&error];
    if (error) {
        _tvRecord.text = error.description;
    } else {
        _tvRecord.text = [NSString stringWithFormat:@"更新%@--->%@成功", value, updateDic];
    }
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

#pragma mark - OHMysqlHelperProtocol

- (void)ohMysqlHelperResponMsg:(NSString *)msg type:(OHMysqlHelperType)type {
    NSString *title = @"连接";
    switch (type) {
        case OHMysqlHelperTypeAdd:
            title = @"添加";
            break;
        case OHMysqlHelperTypeDelete:
            title = @"删除";
            break;
        case OHMysqlHelperTypeUpdate:
            title = @"修改";
            break;
        case OHMysqlHelperTypeQuery:
            title = @"查询";
            break;
        default:
            break;
    }
    [self baseAlertWithTitle:title msg:[NSString stringWithFormat:@"rsp msg:%@", msg]];
}

- (void)ohMysqlHelperErrorMsg:(NSString *)msg type:(OHMysqlHelperType)type {
    NSString *title = @"连接";
    switch (type) {
        case OHMysqlHelperTypeAdd:
            title = @"添加";
            break;
        case OHMysqlHelperTypeDelete:
            title = @"删除";
            break;
        case OHMysqlHelperTypeUpdate:
            title = @"修改";
            break;
        case OHMysqlHelperTypeQuery:
            title = @"查询";
            break;
        default:
            break;
    }
    [self baseAlertWithTitle:title msg:[NSString stringWithFormat:@"错误信息:%@", msg]];
}

@end
