//
//  PFMDBManager.m
//  PFMDB
//
//  Created by hzw598 on 16/10/25.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "PFMDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "PFMDBSqlGenerator.h"
#import "FMDatabaseAdditions.h"
#import "PFMDBTableProtocol.h"
#import <UIKit/UIKit.h>

@implementation PFMDBManager

@synthesize databaseQueues = _databaseQueues;
@synthesize databaseArray = _databaseArray;
@synthesize defaultDatabase = _defaultDatabase;
@synthesize defaultQueue = _defaultQueue;

#pragma mark -Getter/Setter
/**
 *  单例安全初始化方法
 *
 *  @return PFMDBManager
 */
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static PFMDBManager *_pfmdbShareInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _pfmdbShareInstance = [super allocWithZone:zone];
        //添加通知
        [[NSNotificationCenter defaultCenter] addObserver:_pfmdbShareInstance selector:@selector(listenToMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    });
    return _pfmdbShareInstance;
}

- (NSMutableDictionary<NSString *, FMDatabaseQueue *> *)databaseQueues {
    if (!_databaseQueues) {
        _databaseQueues = [NSMutableDictionary dictionary];
    }
    return _databaseQueues;
}

- (NSMutableDictionary<NSString *, FMDatabase *> *)databaseArray {
    if (!_databaseArray) {
        _databaseArray = [NSMutableDictionary dictionary];
    }
    return _databaseArray;
}

//设置默认数据库
- (void)setDefaultDatabase:(FMDatabase *)defaultDatabase {
    if (defaultDatabase == _defaultDatabase) {
        return;
    }
    //关闭数据库及队列
    [self closeDatabase:_defaultDatabase];
    
    //重置
    _defaultDatabase = defaultDatabase;
    _defaultQueue = nil;
    [self.databaseArray setObject:_defaultDatabase forKey:_defaultDatabase.databasePath];
    [_defaultDatabase open];
}

//获取默认数据库
- (FMDatabase *)defaultDatabase {
    if (!_defaultDatabase) {
        NSString *path = [PFMDBManager defaultDatabasePath];
        _defaultDatabase = [self databaseWithPath:path];
        [self.databaseArray setObject:_defaultDatabase forKey:path];
    }
    return _defaultDatabase;
}

//获取默认数据库队列
- (FMDatabaseQueue *)defaultQueue {
    if (!_defaultQueue) {
        NSString *path = self.defaultDatabase.databasePath;
        _defaultQueue = [self queueWithPath:path];
        [self.databaseQueues setObject:_defaultQueue forKey:path];
    }
    return _defaultQueue;
}

/**
 *  获取PFMDB默认数据库路径
 *
 *  @return NSString
 */
+ (NSString *)defaultDatabasePath {
    NSString *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *directory = [paths stringByAppendingPathComponent:@"pfmdb"];
    BOOL isDirectory;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory] || !isDirectory) {
        [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *path = [directory stringByAppendingPathComponent:@"pfmdb.sqlite"];
    NSLog(@"pfmdb.defaultDatabasePath=%@",path);
    return path;
}

/**
 *  接收到内存警告通知
 */
- (void)listenToMemoryWarningNotification:(NSNotification *)notification {
    _databaseArray = nil;
    _databaseQueues = nil;
}

#pragma mark -FMDatabase
/**
 *  单例初始化方法
 *
 *  @return PFMDBManager
 */
+ (instancetype)shareInstance {
    return [[self alloc] init];
}

/**
 *  获取默认数据库的类方法
 *
 *  @return FMDatabase
 */
+ (FMDatabase *)defaultDatabase {
    return [[self shareInstance] defaultDatabase];
}

/**
 *  获取默认数据库队列的类方法
 *
 *  @return FMDatabaseQueue
 */
+ (FMDatabaseQueue *)defaultQueue {
    return [[self shareInstance] defaultQueue];
}

/**
 *  获取数据库
 *
 *  @param path 数据库路径
 *
 *  @return FMDatabase
 */
- (FMDatabase *)databaseWithPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    FMDatabase *db = self.databaseArray[path];
    if (!db) {
        db = [FMDatabase databaseWithPath:path];
        if (db) {
            [self.databaseArray setObject:db forKey:path];
            [db open];
        }
    }
    
    return db;
}

/**
 *  获取数据库队列
 *
 *  @param path 数据库路径
 *
 *  @return FMDatabaseQueue
 */
- (FMDatabaseQueue *)queueWithPath:(NSString *)path {
    if (!path) {
        return nil;
    }
    FMDatabaseQueue *queue = self.databaseQueues[path];
    if (!queue) {
        queue = [FMDatabaseQueue databaseQueueWithPath:path];
        if (queue) {
            [self.databaseQueues setObject:queue forKey:path];
        }
    }
    
    return queue;
}

/**
 *  关闭所有的数据库以及队列, 一般使用在app退出
 */
- (void)close {
    [self.databaseArray enumerateKeysAndObjectsUsingBlock:^(NSString *key, FMDatabase *obj, BOOL * _Nonnull stop) {
        [self closeDatabaseWithPath:key];
    }];
}

/**
 *  关闭特定数据库和队列
 *
 *  @param path 数据库路径
 */
- (void)closeDatabaseWithPath:(NSString *)path {
    FMDatabase *db = self.databaseArray[path];
    if (db) {
        [db close];
        [self.databaseArray removeObjectForKey:path];
    }
    FMDatabaseQueue *queue = self.databaseQueues[path];
    if (queue) {
        [queue close];
        [self.databaseQueues removeObjectForKey:path];
    }
}

/**
 *  关闭特定数据库和队列
 *
 *  @param database 数据库
 */
- (void)closeDatabase:(FMDatabase *)database {
    if (database) {
        [self closeDatabaseWithPath:database.databasePath];
    }
}


#pragma mark -PFMDB Operation
/**
 *  检测数据表是否存在
 *
 *  @param clazz 表名称
 *
 *  @return BOOL
 */
- (BOOL)checkTableExistsByClazz:(Class<PFMDBTableProtocol>)clazz {
    NSString *tableName = [clazz p_className];
    FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
    __block BOOL flag = YES;
    [queue inDatabase:^(FMDatabase *db) {
        flag = [db tableExists:tableName];
        if (!flag) {
            NSLog(@"pfmdb检测表结构是否存在失败");
        }
    }];
    return flag;
}

/**
 *  执行查询
 *
 *  @param sql 查询语句参数
 *
 *  @return FMResultSet
 */
- (FMResultSet *)p_executeQuery:(PFMDBSql *)sql {
//    __block FMResultSet *result = nil;
//    FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
//    [queue inDatabase:^(FMDatabase *db) {
//        result = [db executeQuery:sql.sql withArgumentsInArray:sql.argvs];
//    }];
//    
//    return result;
    return [[[PFMDBManager shareInstance] defaultDatabase] executeQuery:sql.sql withArgumentsInArray:sql.argvs];
}

/**
 *  执行单个更新
 *
 *  @param sql 更新语句参数
 *
 *  @return BOOL
 */
- (BOOL)p_executeUpdateOne:(PFMDBSql *)sql {
    __block BOOL flag = YES;
    FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
    [queue inDatabase:^(FMDatabase *db) {
        flag = [db executeUpdate:sql.sql withArgumentsInArray:sql.argvs];
        if (!flag) {
            NSLog(@"pfmdb执行更新失败：%@ %@", sql.sql, sql.argvs);
        }
    }];
    return flag;
}

/**
 *  执行批量更新
 *
 *  @param sqls 批量更新语句参数
 *
 *  @return BOOL
 */
- (BOOL)p_executeUpdateBatch:(NSArray<PFMDBSql *> *)sqls {
    __block BOOL flag = YES;
    FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (PFMDBSql *sql in sqls) {
            flag = [db executeUpdate:sql.sql withArgumentsInArray:sql.argvs];
            if (!flag) {
                NSLog(@"pfmdb执行批量更新失败：%@ %@", sql.sql, sql.argvs);
                *rollback = YES;
                return;
            }
        }
    }];
    return flag;
}

/**
 *  创建数据表
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_createTableForClazz:(Class<PFMDBTableProtocol>)clazz {
    __block BOOL flag = YES;
    if (![self checkTableExistsByClazz:clazz]) {
        PFMDBSql *sql = [PFMDBSqlGenerator sqlForCreateTableByClazz:clazz];
        FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
        [queue inDatabase:^(FMDatabase *db) {
            flag = [db executeUpdate:sql.sql withArgumentsInArray:sql.argvs];
            if (!flag) {
                NSLog(@"pfmdb创建数据表失败：%@ %@", sql.sql, sql.argvs);
            }
        }];
    }
    return flag;
}

/**
 *  删除数据表
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_dropTableForClazz:(Class<PFMDBTableProtocol>)clazz {
    __block BOOL flag = YES;
    if ([self checkTableExistsByClazz:clazz]) {
        PFMDBSql *sql = [PFMDBSqlGenerator sqlForDropTableByClazz:clazz];
        FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
        [queue inDatabase:^(FMDatabase *db) {
            flag = [db executeUpdate:sql.sql withArgumentsInArray:sql.argvs];
            if (!flag) {
                NSLog(@"pfmdb删除数据表失败：%@ %@", sql.sql, sql.argvs);
            }
        }];
    }
    return flag;
}

/**
 *  重新创建数据表（先删除，后新建）
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_reCreateTableForClazz:(Class<PFMDBTableProtocol>)clazz {
    [self p_dropTableForClazz:clazz];
    return [self p_createTableForClazz:clazz];
}

/**
 *  更新表结构
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_updateTableForClazz:(Class<PFMDBTableProtocol>)clazz {
    FMDatabase *database = [[PFMDBManager shareInstance] defaultDatabase];
    NSArray *sqls = [PFMDBSqlGenerator sqlForUpdateTableByClazz:clazz inDB:database];
    if (sqls.count == 0) {
        return YES;
    }
    __block BOOL flag = YES;
    FMDatabaseQueue *queue = [[PFMDBManager shareInstance] defaultQueue];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (PFMDBSql *sql in sqls) {
            flag = [self p_executeUpdateOne:sql];
            if (!flag) {
                NSLog(@"pfmdb更新数据表失败：%@ %@",sql.sql, sql.argvs);
                *rollback = YES;
                return;
            }
        }
    }];
    
    return flag;
}


@end
