//
//  PFMDBSqlGenerator.m
//  PFMDB
//
//  Created by hzw598 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "PFMDBSqlGenerator.h"
#import "PFMDBTableProtocol.h"
#import "PFMDBObjcProperty.h"
#import "PFMDBClassProtocol.h"
#import "PFMDBTableProperty.h"
#import "PFMDBTableProperty.h"
#import "PFMDBObjcToTableUtil.h"
#import "FMDatabaseAdditions.h"
#import "PFMDBQueryCondition.h"

@implementation PFMDBSql

+ (instancetype)sql:(NSString *)sql argvs:(NSArray *)argvs
{
    PFMDBSql *pSql = [[PFMDBSql alloc] init];
    pSql->_sql = sql;
    pSql->_argvs = argvs;
    
    return pSql;
}

@end

@implementation PFMDBLimit

+ (instancetype)limit:(NSInteger)limit offset:(NSInteger)offset
{
    PFMDBLimit *pLimit = [[PFMDBLimit alloc] init];
    pLimit->_limit = limit;
    pLimit->_offset = offset;
    
    return pLimit;
}

@end

@implementation PFMDBSqlGenerator

/**
 *  生成建表语句
 *
 *  @param clazz 对应类
 *
 *  @return 建表语句
 */
+ (PFMDBSql *)sqlForCreateTableByClazz:(Class<PFMDBTableProtocol>)clazz {
    //获取db字段属性
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    
    //获取表名称
    NSString *tableName = [clazz p_className];
    NSString *pkName = [clazz p_customPrimarykey];
    
    //声明sql语句
    NSMutableString *sql = [NSMutableString string];
    if (!pkName) {
        //创建主键
        [sql appendFormat:@"create table if not exists %@ (%@ INTEGER primary key autoincrement", tableName, PFMDB_DEFAULT_PRIMARYKEY];
        pkName = [PFMDB_DEFAULT_PRIMARYKEY copy];
    }
    
    //循环遍历字段属性数组并创建sql语句
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        //自定义主键，创建主键
        if ([obj.name isEqualToString:pkName]) {
            [sql appendFormat:@"create table if not exists %@ (%@ %@ primary key", tableName, obj.name, obj.type];
        } else {
            //添加字段
            [sql appendFormat:@", %@ %@", obj.name, obj.type];
        }
        
    }];
    
    [sql appendString:@") ;"];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:nil];
    
    return pSql;
}

/**
 *  生成删表语句
 *
 *  @param clazz 对应类
 *
 *  @return 删表语句
 */
+ (PFMDBSql *)sqlForDropTableByClazz:(Class<PFMDBTableProtocol>)clazz {
    //获取表名称
    NSString *tableName = [clazz p_className];
    NSString *sql = [NSString stringWithFormat:@"drop table if exists %@ ;", tableName];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:nil];
    
    return pSql;
}

/**
 *  因为sqlite不支持批量添加字段，只能返回多条语句，多次更新表
 *
 *  @param clazz 对应类
 *  @param db    数据库
 *
 *  @return 更新表语句数组
 */
+ (NSArray<PFMDBSql *> *)sqlForUpdateTableByClazz:(Class<PFMDBTableProtocol>)clazz inDB:(FMDatabase *)db
{
    //获取db字段属性
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    
    //获取表名称
    NSString *tableName = [clazz p_className];
    
    //检测表是否存在, 不存在则直接返回创建表语句
    if ([db open]) {
        if (![db tableExists:tableName]) {
            PFMDBSql *pSql = [self sqlForCreateTableByClazz:clazz];
            return @[pSql];
        }
    }
    
    //声明更新语句数组
    NSMutableArray *pSqls = [NSMutableArray array];
    //主键字段
    NSString *pkName = [clazz p_primaryKey];
    
    //循环遍历字段属性数组并创建sql语句
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        //主键已创建，不需要再添加该字段
        if ([obj.name isEqualToString:pkName]) {
            return;
        }
        //如果表字段已存在，则继续
        if ([db columnExists:obj.name inTableWithName:tableName]) {
            return;
        }
        
        NSString *sql = [NSString stringWithFormat:@"alter table %@ add column %@ %@ ;", tableName, obj.name, obj.type];
        PFMDBSql *pSql = [PFMDBSql sql:sql argvs:nil];
        [pSqls addObject:pSql];
    }];
    
    return pSqls;
}

/**
 *  新增数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql insert into tablename values (name= ? , name2 = ?,)
 */
+ (PFMDBSql *)sqlForInsertByObjc:(id<PFMDBTableProtocol>)objc {
    Class clazz = [objc class];
    //获取db字段属性
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    
    //获取表名
    NSString *tableName = [clazz p_className];
    
    //insert sql
    __block NSMutableString *insertSql = nil;
    
    //value sql
    __block NSMutableString *valueSql = nil;
    
    //字段值
    NSMutableArray *argvsList = [NSMutableArray array];
    
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        if (!insertSql) {
            insertSql = [NSMutableString string];
            [insertSql appendFormat:@"insert into %@ ( %@", tableName,obj.name];
        } else {
            [insertSql appendFormat:@", %@",obj.name];
        }
        if (!valueSql) {
            valueSql = [NSMutableString string];
            [valueSql appendString:@" values ( ?"];
        } else {
            [valueSql appendFormat:@", ?"];
        }
        
        id value = [(NSObject *)objc valueForKey:obj.name];
        if (!value) {
            value = [NSNull null];
        }
        //字段值
        [argvsList addObject:value];
    }];
    
    [insertSql appendFormat:@" )"];
    [valueSql appendFormat:@" ) ;"];
    
    [insertSql appendString:valueSql];
    
    PFMDBSql *pSql = [PFMDBSql sql:insertSql argvs:argvsList];
    
    return pSql;
}

/**
 *  更新数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql update tablename set name = ?, name2 = ? where ID = ?
 */
+ (PFMDBSql *)sqlForUpdateByObjc:(id<PFMDBTableProtocol>)objc {
    Class clazz = [objc class];
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    NSString *tableName = [clazz p_className];
    //主键字段
    NSString *pkName = [clazz p_primaryKey];
    
    //sql语句
    __block NSMutableString *sql = nil;
    //字段值
    NSMutableArray *argvsList = [NSMutableArray array];
    
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqualToString:pkName]) {
            return;
        }
        
        if (!sql) {
            sql = [NSMutableString string];
            [sql appendFormat:@"update %@ set %@=?", tableName, obj.name];
        } else {
            [sql appendFormat:@" , %@=?", obj.name];
        }
        
        id value = [(NSObject *)objc valueForKey:obj.name];
        if (!value) {
            value = [NSNull null];
        }
        [argvsList addObject:value];
    }];
    
    [sql appendFormat:@" where %@=? ;", pkName];
    id value = [(NSObject *)objc valueForKey:pkName];
    if (!value) {
        value = @1;
    }
    [argvsList addObject:value];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvsList];
    
    return pSql;
}

/**
 *  插入或更新数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql insert or replace into tablename values (?, ?, ...)
 */
+ (PFMDBSql *)sqlForSaveOrUpdateByObjc:(id<PFMDBTableProtocol>)objc {
    Class clazz = [objc class];
    //获取db字段属性
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    
    //获取表名
    NSString *tableName = [clazz p_className];
    NSString *pkName = [clazz p_customPrimarykey];
    
    //insertOrReplaceSql
    __block NSMutableString *insertOrReplaceSql = nil;
    
    //value sql
    __block NSMutableString *valueSql = nil;
    
    //字段值
    NSMutableArray *argvsList = [NSMutableArray array];
    if (!pkName) {
        //没有自定义主键，则为自增长主键
        NSNumber *incrementId = [objc incrementId];
        if (incrementId) {
            
            insertOrReplaceSql = [NSMutableString string];
            [insertOrReplaceSql appendFormat:@"insert or replace into %@ ( %@", tableName, PFMDB_DEFAULT_PRIMARYKEY];
            
            valueSql = [NSMutableString string];
            [valueSql appendString:@" values ( ?"];
            
            [argvsList addObject:incrementId];
        }
    }
    
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        if (!insertOrReplaceSql) {
            insertOrReplaceSql = [NSMutableString string];
            [insertOrReplaceSql appendFormat:@"insert or replace into %@ ( %@", tableName, obj.name];
        } else {
            [insertOrReplaceSql appendFormat:@", %@", obj.name];
        }
        if (!valueSql) {
            valueSql = [NSMutableString string];
            [valueSql appendString:@" values ( ?"];
        } else {
            [valueSql appendFormat:@", ?"];
        }
        
        id value = [(NSObject *)objc valueForKey:obj.name];
        if (!value) {
            value = [NSNull null];
        }
        //字段值
        [argvsList addObject:value];
    }];
    
    [insertOrReplaceSql appendFormat:@" )"];
    [valueSql appendFormat:@" ) ;"];
    
    [insertOrReplaceSql appendString:valueSql];
    
    PFMDBSql *pSql = [PFMDBSql sql:insertOrReplaceSql argvs:argvsList];
    
    return pSql;
}

/**
 *  删除数据语句
 *
 *  @param objc 数据对象
 *
 *  @return 返回占位符的sql delete from tablename where [primaryKeyName] = ?
 */
+ (PFMDBSql *)sqlForDeleteByObjc:(id<PFMDBTableProtocol>)objc {
    Class clazz = [objc class];
    NSString *tableName = [clazz p_className];
    //主键字段
    NSString *pkName = [clazz p_primaryKey];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@=? ;", tableName, pkName];
    NSMutableArray *argvsList = [NSMutableArray array];
    
    id value = [(NSObject *)objc valueForKey:pkName];
    if (!value) {
        value = @1;
    }
    [argvsList addObject:value];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvsList];
    
    return pSql;
}

/**
 *  删除全部数据语句
 *
 *  @param clazz 对应类
 *
 *  @return 返回占位符的sql delete from tablename
 */
+ (PFMDBSql *)sqlForDeleteAllByClazz:(Class<PFMDBTableProtocol>)clazz {
    
    NSString *tableName = [clazz p_className];
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ ", tableName];
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:nil];
    
    return pSql;
}

/**
 *  根据主键查询数据
 *
 *  @param pkValue 主键值
 *  @param clazz   对应类
 *
 *  @return 返回占位符的sql（select * from tablename where [pkName] = ?）
 */
+ (PFMDBSql *)sqlForQueryByPrimaryKeyValue:(id)pkValue inClazz:(Class<PFMDBTableProtocol>)clazz
{
    NSString *tableName = [clazz p_className];
    NSString *pkName = [clazz p_primaryKey];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=? ;", tableName, pkName];
    
    NSArray *argvsList = @[pkValue];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvsList];
    
    return pSql;
}

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
                              inClazz:(Class<PFMDBTableProtocol>)clazz
{
    NSString *tableName = [clazz p_className];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@=? ;", tableName, columnName];
    
    NSArray *argvsList = @[columnValue];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvsList];
    
    return pSql;
}

/**
 *  查找所有数据
 *
 *  @param clazz 对应类
 *
 *  @return 返回占位符的sql select * from tablename
 */
+ (PFMDBSql *)sqlForQueryAllByClazz:(Class<PFMDBTableProtocol>)clazz {
    
    NSString *tableName = [clazz p_className];
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@ ;", tableName];
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:nil];
    
    return pSql;
}

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
                               isDESC:(BOOL)isDESC
{
    
    NSString *tableName = [clazz p_className];
    
    NSMutableString *sql = [NSMutableString string];
    NSMutableArray *argvs = [NSMutableArray array];
    
    [sql appendFormat:@"select * from %@ ", tableName];
    
    //判断是否有条件
    if (conditions) {
        [sql appendFormat:@"where %@ ", conditions.conditions];
        [argvs addObjectsFromArray:conditions.argvs];
    }
    
    //判断是否排序
    if (orderColumnName) {
        [sql appendFormat:@"order by %@ ", orderColumnName];
        if (isDESC) {
            [sql appendString:@"DESC "];
        }
    } else {
        //以主键排序
        if (isDESC) {
            NSString *pkName = [clazz p_primaryKey];
            [sql appendFormat:@"order by %@ DESC ", pkName];
        }
    }
    
    //判断是否有分页
    if (limit) {
        [sql appendString:@"limit ? offset ? "];
        [argvs addObjectsFromArray:@[@(limit.limit), @(limit.offset)]];
    }
    
    [sql appendString:@";"];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvs];
    
    return pSql;
}

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
                              inClazz:(Class<PFMDBTableProtocol>)clazz
{
    NSString *tableName = [clazz p_className];
    
    NSMutableString *sql = [NSMutableString string];
    
    [sql appendFormat:@"select * from %@ where %@", tableName, conditions];
    
    PFMDBSql *pSql = [PFMDBSql sql:sql argvs:argvs];
    
    return pSql;
}



@end
