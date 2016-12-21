//
//  NSObject+PFMDB.h
//  PFMDB
//
//  Created by hzw598 on 16/10/21.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFMDBTableProtocol.h"

@interface NSObject (PFMDB) <PFMDBTableProtocol>

/**
 *  保存数据
 *
 *  @return BOOL
 */
- (BOOL)p_save;

/**
 *  保存或更新
 *
 *  @return BOOL
 */
- (BOOL)p_saveOrUpdate;

/**
 *  更新数据
 *
 *  @return BOOL
 */
- (BOOL)p_update;

/**
 *  删除数据
 *
 *  @return BOOL
 */
- (BOOL)p_delete;

/**
 *  删除所有数据
 *
 *  @return BOOL
 */
+ (BOOL)p_deleteAll;

/**
 *  查询所有数据
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryAll;

/**
 *  根据主键查询数据
 *
 *  @param pkValue 主键值
 *
 *  @return NSObject
 */
+ (instancetype)p_queryByPrimarykey:(id)pkValue;

/**
 *  根据某个字段查询数据
 *
 *  @param columnName  字段名
 *  @param columnValue 字段值
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryByColumnName:(NSString *)columnName columnValue:(id)columnValue;

/**
 *  查询总记录数
 *
 *  @return long
 */
+ (long)p_queryTotalCount;

/**
 *  分页查询查询数据
 *
 *  @param page     起始页
 *  @param pageSize 页数大小
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryByPage:(NSInteger)page pageSize:(NSInteger)pageSize;

/**
 *  更新表结构
 *
 *  @return BOOL
 */
+ (BOOL)p_updateTable;

/**
 *  删除数据表
 *
 *  @return BOOL
 */
+ (BOOL)p_dropTable;

/**
 *  根据条件语句查询数据
 *
 *  @param conditions   条件语句，如：@"name like ?"、@"name=? or name=?  order by incrementId"
 *  @param argvs        对应条件语句参数值，如：@[@"%hzw%"]、@[@"hzw", @"hzw598"]
 *
 *  @return NSArray
 */
+ (NSArray *)p_queryByConditions:(NSString *)conditions argvs:(NSArray *)argvs;

@end
