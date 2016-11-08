//
//  NSObject+PFMDB.m
//  PFMDB
//
//  Created by 周爱林 on 16/10/21.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "NSObject+PFMDB.h"
#import "PFMDBSqlGenerator.h"
#import "PFMDBObjcProperty.h"
#import "PFMDBTableProperty.h"
#import "PFMDBObjcToTableUtil.h"
#import "PFMDBManager.h"
#import "FMResultSet.h"

@implementation NSObject (PFMDB)

static const NSString *PFMDB_INCREMENTIDKEY = @"PFMDB_INCREMENTIDKEY";

#pragma mark -Attributes
/**
 *  设置自增长主键值（主要是从数据表读取数据时设置）
 *
 *  @param incrementId 主键值
 */
- (void)setIncrementId:(NSNumber *)incrementId {
    objc_setAssociatedObject(self, &PFMDB_INCREMENTIDKEY, incrementId, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
/**
 *  获取自增长主键值
 *
 *  @return 主键值
 */
- (NSNumber *)incrementId {
    return objc_getAssociatedObject(self, &PFMDB_INCREMENTIDKEY);
}


/**
 *  设置自定义的数据表主键字段
 *
 *  @return 字段全名
 */
+ (NSString *)p_customPrimarykey {
    return nil;
}

/**
 *  如果有自定义主键，则返回自定义主键key，例如 name，若没有实现，则返回默认自增长主键key ： PFMDB_DEFAULT_PRIMARYKEY
 *
 *  @return 主键的字段名
 */
+ (NSString *)p_primaryKey {
    if ([self p_customPrimarykey]) {
        return [self p_customPrimarykey];
    }
    return PFMDB_DEFAULT_PRIMARYKEY;
}

/**
 *  获取主键对应的值
 *
 *  @return 主键值
 */
- (id)p_primaryKeyValue {
    NSString *pkName = [[self class] p_primaryKey];
    id value = [self valueForKey:pkName];
    return value;
}

/**
 *  激活表字段属性
 *
 *  @return 表字段属性数组
 */
+ (NSArray<PFMDBTableProperty *> *)p_activateProperties {
    NSArray<PFMDBObjcProperty *> *objcProperties = [[self class] p_properties];
    NSArray<PFMDBTableProperty *> *tableProperties = [PFMDBObjcToTableUtil changeToDbByObjcProperties:objcProperties];
    return tableProperties;
}


#pragma mark -Private
//保存单个对象
- (BOOL)p_saveOne {
    //创建表
    Class clazz = [self class];
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForInsertByObjc:self];
    flag = [[PFMDBManager shareInstance] p_executeUpdateOne:sql];
    
    return flag;
}

//保存批量对象
- (BOOL)p_saveBatch {
    Class<PFMDBTableProtocol> clazz;
    NSInteger objcCount = 0;
    //如果是数组，需要获取到class
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)self;
        objcCount = array.count;
        if (objcCount == 0) {
            return YES;
        }
        id objc = [array firstObject];
        clazz = [objc class];
    }
    //创建表
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    if (flag) {
        //添加数据
        NSMutableArray<PFMDBSql *> *sqls = [NSMutableArray arrayWithCapacity:objcCount];
        NSArray *array = (NSArray *)self;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFMDBSql *sql = [PFMDBSqlGenerator sqlForInsertByObjc:obj];
            [sqls addObject:sql];
        }];
        flag = [[PFMDBManager shareInstance] p_executeUpdateBatch:sqls];
    }
    
    return flag;
}

//更新单个对象
- (BOOL)p_updateOne {
    //创建表
    Class clazz = [self class];
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    if (flag) {
        PFMDBSql *sql = [PFMDBSqlGenerator sqlForUpdateByObjc:self];
        flag = [[PFMDBManager shareInstance] p_executeUpdateOne:sql];
    }
    
    return flag;
}

//更新批量对象
- (BOOL)p_updateBatch {
    Class<PFMDBTableProtocol> clazz;
    NSInteger objcCount = 0;
    //如果是数组，需要获取到class
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)self;
        objcCount = array.count;
        if (objcCount == 0) {
            return YES;
        }
        id objc = [array firstObject];
        clazz = [objc class];
    }
    //创建表
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    if (flag) {
        //添加数据
        NSMutableArray<PFMDBSql *> *sqls = [NSMutableArray arrayWithCapacity:objcCount];
        NSArray *array = (NSArray *)self;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFMDBSql *sql = [PFMDBSqlGenerator sqlForUpdateByObjc:obj];
            [sqls addObject:sql];
        }];
        flag = [[PFMDBManager shareInstance] p_executeUpdateBatch:sqls];
    }
    
    return flag;
}

//保存或更新单个对象
- (BOOL)p_saveOrUpdateOne {
    //创建表
    Class clazz = [self class];
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForSaveOrUpdateByObjc:self];
    flag = [[PFMDBManager shareInstance] p_executeUpdateOne:sql];
    
    return flag;
}

//保存或更新批量对象
- (BOOL)p_saveOrUpdateBatch {
    Class<PFMDBTableProtocol> clazz;
    NSInteger objcCount = 0;
    //如果是数组，需要获取到class
    if ([self isKindOfClass:[NSArray class]]) {
        NSArray *array = (NSArray *)self;
        objcCount = array.count;
        if (objcCount == 0) {
            return YES;
        }
        id objc = [array firstObject];
        clazz = [objc class];
    }
    //创建表
    BOOL flag = [[PFMDBManager shareInstance] p_createTableForClazz:clazz];
    if (flag) {
        //添加数据
        NSMutableArray<PFMDBSql *> *sqls = [NSMutableArray arrayWithCapacity:objcCount];
        NSArray *array = (NSArray *)self;
        [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PFMDBSql *sql = [PFMDBSqlGenerator sqlForSaveOrUpdateByObjc:obj];
            [sqls addObject:sql];
        }];
        flag = [[PFMDBManager shareInstance] p_executeUpdateBatch:sqls];
    }
    
    return flag;
}

//删除单个对象
- (BOOL)p_deleteOne {
    //获取sql
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForDeleteByObjc:self];
    //执行删除
    return [[PFMDBManager shareInstance] p_executeUpdateOne:sql];
}

//删除批量对象
- (BOOL)p_deleteBatch {
    //获取sql
    NSMutableArray<PFMDBSql *> *sqls = [NSMutableArray array];
    NSArray *array = (NSArray *)self;
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        PFMDBSql *sql = [PFMDBSqlGenerator sqlForDeleteByObjc:obj];
        [sqls addObject:sql];
    }];
    //执行删除
    return [[PFMDBManager shareInstance] p_executeUpdateBatch:sqls];
}

//根据结果集转化为对象
+ (instancetype)generateToObjectByResultSet:(FMResultSet *)rs
                                     pkName:(NSString *)pkName
                            tableProperties:(NSArray<PFMDBTableProperty *> *)tableProperties
{
    NSObject<PFMDBTableProtocol> *objc = [[self alloc] init];
    if (!pkName) {
        NSNumber *pkValue = @([rs longForColumn:PFMDB_DEFAULT_PRIMARYKEY]);
        [objc setIncrementId:pkValue];
    }
    //获取字段值并设置属性值
    [tableProperties enumerateObjectsUsingBlock:^(PFMDBTableProperty *obj, NSUInteger idx, BOOL *stop) {
        id value = nil;
        switch (obj.dataType) {
            case PFMDBDataTypeInt:
                value = @([rs intForColumn:obj.name]);
                break;
            case PFMDBDataTypeLong:
                value = @([rs longForColumn:obj.name]);
                break;
            case PFMDBDataTypeULong:
                value = @([rs unsignedLongLongIntForColumn:obj.name]);
                break;
            case PFMDBDataTypeDouble:
                value = @([rs doubleForColumn:obj.name]);
                break;
            case PFMDBDataTypeString:
                value = [rs stringForColumn:obj.name];
                break;
            case PFMDBDataTypeNSNumber:
                value = @([rs doubleForColumn:obj.name]);
                break;
            case PFMDBDataTypeNSData:
                value = [rs dataForColumn:obj.name];
                break;
            case PFMDBDataTypeNSDate:
                value = [rs dateForColumn:obj.name];
                break;
            default:
                break;
        }
        
        if (value) {
            [objc setValue:value forKey:obj.name];
        }
    }];
    
    return objc;
}


#pragma mark -FMDB
/**
 *  保存数据
 *
 *  @return BOOL
 */
- (BOOL)p_save {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    BOOL flag = YES;
    //如果是数组，则批量保存
    if ([self isKindOfClass:[NSArray class]]) {
        flag = [self p_saveBatch];
    } else {
        flag = [self p_saveOne];
    }
    
    return flag;
}

/**
 *  保存或更新
 *
 *  @return BOOL
 */
- (BOOL)p_saveOrUpdate {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    BOOL flag = YES;
    //如果是数组，则批量保存或更新
    if ([self isKindOfClass:[NSArray class]]) {
        flag = [self p_saveOrUpdateBatch];
    } else {
        flag = [self p_saveOrUpdateOne];
    }
    
    return flag;
}

/**
 *  更新数据
 *
 *  @return BOOL
 */
- (BOOL)p_update {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    BOOL flag = YES;
    //如果是数组，则批量更新
    if ([self isKindOfClass:[NSArray class]]) {
        flag = [self p_updateBatch];
    } else {
        flag = [self p_updateOne];
    }
    
    return flag;
}

/**
 *  删除数据
 *
 *  @return BOOL
 */
- (BOOL)p_delete {
    if ([self isKindOfClass:[NSDictionary class]]) {
        return NO;
    }
    BOOL flag = YES;
    //如果是数组，则批量删除
    if ([self isKindOfClass:[NSArray class]]) {
        flag = [self p_deleteBatch];
    } else {
        flag = [self p_deleteOne];
    }
    
    return flag;
}

/**
 *  删除所有数据
 *
 *  @return BOOL
 */
+ (BOOL)p_deleteAll {
    //创建表
    Class clazz = [self class];
    
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForDeleteAllByClazz:clazz];
    
    return [[PFMDBManager shareInstance] p_executeUpdateOne:sql];
}

/**
 *  查询所有数据
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryAll {
    //对象数组
    NSMutableArray<PFMDBTableProtocol> *objcArray = [NSMutableArray array];
    //类相关
    Class clazz = [self class];
    __block NSString *pkName = [clazz p_customPrimarykey];
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForQueryAllByClazz:clazz];
    FMResultSet *rs = [[PFMDBManager shareInstance] p_executeQuery:sql];
    while ([rs next]) {
        NSObject<PFMDBTableProtocol> *objc = [self generateToObjectByResultSet:rs pkName:pkName tableProperties:tableProperties];
        [objcArray addObject:objc];
    }
    
    [rs close];
    
    return objcArray;
}

/**
 *  根据主键查询数据
 *
 *  @param pkValue 主键值
 *
 *  @return NSObject
 */
+ (instancetype)p_queryByPrimarykey:(id)pkValue {
    //对象
    NSObject<PFMDBTableProtocol> *objc = nil;
    //类相关
    Class clazz = [self class];
    __block NSString *pkName = [clazz p_customPrimarykey];
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForQueryByPrimaryKeyValue:pkValue inClazz:clazz];
    FMResultSet *rs = [[PFMDBManager shareInstance] p_executeQuery:sql];
    if ([rs next]) {
        objc = [self generateToObjectByResultSet:rs pkName:pkName tableProperties:tableProperties];
    }
    
    [rs close];
    
    return objc;
}

/**
 *  根据某个字段查询数据
 *
 *  @param columnName  字段名
 *  @param columnValue 字段值
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryByColumnName:(NSString *)columnName columnValue:(id)columnValue
{
    //对象数组
    NSMutableArray<PFMDBTableProtocol> *objcArray = [NSMutableArray array];
    //类相关
    Class clazz = [self class];
    NSString *pkName = [clazz p_primaryKey];
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForQueryByColumnName:columnName columnValue:columnValue inClazz:clazz];
    FMResultSet *rs = [[PFMDBManager shareInstance] p_executeQuery:sql];
    while ([rs next]) {
        NSObject<PFMDBTableProtocol> *objc = [self generateToObjectByResultSet:rs pkName:pkName tableProperties:tableProperties];
        [objcArray addObject:objc];
    }
    
    [rs close];
    
    return objcArray;
}

/**
 *  查询总记录数
 *
 *  @return long
 */
+ (long)p_queryTotalCount{
    long totalCount = 0;
    //类相关
    Class clazz = [self class];
    NSString *tableName = [clazz p_className];
    NSString *pkName = [clazz p_primaryKey];
    NSString *sql = [NSString stringWithFormat:@"select count(%@) total from %@", pkName, tableName];
    PFMDBSql *pfmdbSql = [PFMDBSql sql:sql argvs:nil];
    FMResultSet *rs = [[PFMDBManager shareInstance] p_executeQuery:pfmdbSql];
    if ([rs next]) {
        totalCount = [rs longForColumn:@"total"];
    }
    [rs close];
    
    return totalCount;
}

/**
 *  分页查询查询数据
 *
 *  @param page     起始页
 *  @param pageSize 页数大小
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryByPage:(NSInteger)page pageSize:(NSInteger)pageSize {
    //对象数组
    NSMutableArray<PFMDBTableProtocol> *objcArray = [NSMutableArray array];
    //类相关
    Class clazz = [self class];
    NSString *pkName = [clazz p_primaryKey];
    NSArray<PFMDBTableProperty *> *tableProperties = [clazz p_activateProperties];
    PFMDBLimit *limit = [PFMDBLimit limit:pageSize offset:page*pageSize];
    PFMDBSql *sql = [PFMDBSqlGenerator sqlForQueryByConditions:nil inClazz:clazz limit:limit orderBy:pkName isDESC:NO];
    FMResultSet *rs = [[PFMDBManager shareInstance] p_executeQuery:sql];
    while ([rs next]) {
        NSObject<PFMDBTableProtocol> *objc = [self generateToObjectByResultSet:rs pkName:pkName tableProperties:tableProperties];
        [objcArray addObject:objc];
    }
    
    [rs close];
    
    return objcArray;
}

/**
 *  更新表结构
 *
 *  @return BOOL
 */
+ (BOOL)p_updateTable {
    //对应类
    Class clazz = [self class];
    
    return [[PFMDBManager shareInstance] p_updateTableForClazz:clazz];
}

/**
 *  删除数据表
 *
 *  @return BOOL
 */
+ (BOOL)p_dropTable {
    //对应类
    Class clazz = [self class];
    
    return [[PFMDBManager shareInstance] p_dropTableForClazz:clazz];
}


@end
