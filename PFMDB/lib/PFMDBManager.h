//
//  PFMDBManager.h
//  PFMDB
//  数据库管理工具
//  Created by 周爱林 on 16/10/25.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFMDBTableProtocol;

@class FMDatabase;
@class FMDatabaseQueue;
@class PFMDBSql;
@class FMResultSet;

@interface PFMDBManager : NSObject

@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, FMDatabaseQueue *> *databaseQueues;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSString *, FMDatabase *> *databaseArray;
@property (nonatomic, strong) FMDatabase *defaultDatabase;//默认数据库，路径为documents/pfmdb/pfmdb.sqlite
@property (nonatomic, strong, readonly) FMDatabaseQueue *defaultQueue;//默认数据库队列

#pragma mark -FMDatabase
/**
 *  单例初始化方法
 *
 *  @return PFMDBManager
 */
+ (instancetype)shareInstance;

/**
 *  获取PFMDB默认数据库路径
 *
 *  @return NSString
 */
+ (NSString *)defaultDatabasePath;

/**
 *  获取默认数据库的类方法
 *
 *  @return FMDatabase
 */
+ (FMDatabase *)defaultDatabase;

/**
 *  获取默认数据库队列的类方法
 *
 *  @return FMDatabaseQueue
 */
+ (FMDatabaseQueue *)defaultQueue;

/**
 *  获取数据库
 *
 *  @param path 数据库路径
 *
 *  @return FMDatabase
 */
- (FMDatabase *)databaseWithPath:(NSString *)path;

/**
 *  获取数据库队列
 *
 *  @param path 数据库路径
 *
 *  @return FMDatabaseQueue
 */
- (FMDatabaseQueue *)queueWithPath:(NSString *)path;

/**
 *  关闭所有的数据库以及队列, 一般使用在app退出
 */
- (void)close;

/**
 *  关闭特定数据库和队列
 *
 *  @param path 数据库路径
 */
- (void)closeDatabaseWithPath:(NSString *)path;

/**
 *  关闭特定数据库和队列
 *
 *  @param database 数据库
 */
- (void)closeDatabase:(FMDatabase *)database;


#pragma mark -PFMDB Operation
/**
 *  执行查询
 *
 *  @param sql 查询语句参数
 *
 *  @return FMResultSet
 */
- (FMResultSet *)p_executeQuery:(PFMDBSql *)sql;

/**
 *  执行单个更新
 *
 *  @param sql 更新语句参数
 *
 *  @return BOOL
 */
- (BOOL)p_executeUpdateOne:(PFMDBSql *)sql;

/**
 *  执行批量更新
 *
 *  @param sqls 批量更新语句参数
 *
 *  @return BOOL
 */
- (BOOL)p_executeUpdateBatch:(NSArray<PFMDBSql *> *)sqls;

/**
 *  创建数据表
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_createTableForClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  删除数据表
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_dropTableForClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  重新创建数据表（先删除，后新建）
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_reCreateTableForClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  更新表结构
 *
 *  @param clazz 数据表对应类
 *
 *  @return BOOL
 */
- (BOOL)p_updateTableForClazz:(Class<PFMDBTableProtocol>)clazz;


@end
