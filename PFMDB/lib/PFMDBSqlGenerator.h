//
//  PFMDBSqlGenerator.h
//  PFMDB
//  sql语句生成器
//  Created by hzw598 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFMDBTableProtocol;

@class FMDatabase;
@class PFMDBQueryCondition;

@interface PFMDBSql : NSObject

@property (nonatomic, copy, readonly) NSString *sql;
@property (nonatomic, copy, readonly) NSArray *argvs;

/**
 *  初始化方法
 *
 *  @param sql   sql语句
 *  @param argvs 参数值数组
 *
 *  @return PFMDBSql
 */
+ (instancetype)sql:(NSString *)sql argvs:(NSArray *)argvs;

@end

@interface PFMDBLimit : NSObject

@property (nonatomic, readonly) NSInteger limit;//限制量，即查询数目
@property (nonatomic, readonly) NSInteger offset;//偏移量，即起始位置

/**
 *  初始化方法
 *
 *  @param limit  查询数目
 *  @param offset 起始位置
 *
 *  @return PFMDBLimit
 */
+ (instancetype)limit:(NSInteger)limit offset:(NSInteger)offset;

@end


@interface PFMDBSqlGenerator : NSObject

/**
 *  生成建表语句
 *
 *  @param clazz 对应类
 *
 *  @return 建表语句
 */
+ (PFMDBSql *)sqlForCreateTableByClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  生成删表语句
 *
 *  @param clazz 对应类
 *
 *  @return 删表语句
 */
+ (PFMDBSql *)sqlForDropTableByClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  因为sqlite不支持批量添加字段，只能返回多条语句，多次更新表
 *
 *  @param clazz 对应类
 *  @param db    数据库
 *
 *  @return 更新表语句数组
 */
+ (NSArray<PFMDBSql *> *)sqlForUpdateTableByClazz:(Class<PFMDBTableProtocol>)clazz inDB:(FMDatabase *)db;

/**
 *  新增数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql insert into tablename values (name= ? , name2 = ?, ...)
 */
+ (PFMDBSql *)sqlForInsertByObjc:(id<PFMDBTableProtocol>)objc;

/**
 *  更新数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql update tablename set name = ?, name2 = ? where ID = ?
 */
+ (PFMDBSql *)sqlForUpdateByObjc:(id<PFMDBTableProtocol>)objc;

/**
 *  插入或更新数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql insert or replace into tablename values (?, ?, ...)
 */
+ (PFMDBSql *)sqlForSaveOrUpdateByObjc:(id<PFMDBTableProtocol>)objc;

/**
 *  删除数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql delete from tablename where [primaryKeyName] = ?
 */
+ (PFMDBSql *)sqlForDeleteByObjc:(id<PFMDBTableProtocol>)objc;

/**
 *  删除全部数据语句
 *
 *  @param clazz 对应类
 *
 *  @return 返回占位符的sql delete from tablename
 */
+ (PFMDBSql *)sqlForDeleteAllByClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  根据主键查询数据
 *
 *  @param pkValue 主键值
 *  @param clazz   对应类
 *
 *  @return 返回占位符的sql（select * from tablename where [pkName] = ?）
 */
+ (PFMDBSql *)sqlForQueryByPrimaryKeyValue:(id)pkValue
                                   inClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  根据字段名查询数据
 *
 *  @param columnName  字段名
 *  @param columnValue 字段名
 *  @param clazz       对应类
 *
 *  @return 返回占位符的sql select * from tablename where [columnName] = ?
 */
+ (PFMDBSql *)sqlForQueryByColumnName:(NSString *)columnName
                          columnValue:(id)columnValue
                              inClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  查找所有数据
 *
 *  @param clazz 对应类
 *
 *  @return 返回占位符的sql select * from tablename
 */
+ (PFMDBSql *)sqlForQueryAllByClazz:(Class<PFMDBTableProtocol>)clazz;

/**
 *  根据条件查询数据
 *
 *  @param conditions      条件（可为空）
 *  @param clazz           对应类
 *  @param limit           分页参数（可为空）
 *  @param orderColumnName 排序字段名（可为空）
 *  @param isDESC          是否倒序
 *
 *  @return 返回占位符的sql select * from tablename where conditions = ? limit ? offset ? order by ?
 */
+ (PFMDBSql *)sqlForQueryByConditions:(PFMDBQueryCondition *)conditions
                              inClazz:(Class<PFMDBTableProtocol>)clazz
                                limit:(PFMDBLimit *)limit
                              orderBy:(NSString *)orderColumnName
                               isDESC:(BOOL)isDESC;

/**
 *  根据条件查询数据
 *
 *  @param conditions   条件语句
 *  @param argvs        条件语句对应值
 *  @param clazz        对应类
 *
 *  @return 返回占位符的sql select * from tablename
 */
+ (PFMDBSql *)sqlForQueryByConditions:(NSString *)conditions
                                argvs:(NSArray *)argvs
                              inClazz:(Class<PFMDBTableProtocol>)clazz;

@end
