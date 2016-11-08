//
//  PFMDBTableProtocol.h
//  PFMDB
//
//  Created by 周爱林 on 16/10/21.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFMDBClassProtocol.h"

@class PFMDBTableProperty;

@protocol PFMDBTableProtocol <PFMDBClassProtocol>

#define PFMDB_DEFAULT_PRIMARYKEY @"incrementId"

@optional
/**
 *  设置自增长主键值（主要是从数据表读取数据时设置）
 *
 *  @param incrementId 主键值
 */
- (void)setIncrementId:(NSNumber *)incrementId;

/**
 *  获取自增长主键值
 *
 *  @return 主键值
 */
- (NSNumber *)incrementId;


/**
 *  设置自定义的数据表主键字段
 *
 *  @return 字段全名
 */
+ (NSString *)p_customPrimarykey;

/**
 *  如果有自定义主键，则返回自定义主键key，例如 name，若没有实现，则返回默认自增长主键key ： @"incrementId"
 *
 *  @return 主键的字段名
 */
+ (NSString *)p_primaryKey;

/**
 *  获取主键对应的值
 *
 *  @return 主键值
 */
- (id)p_primaryKeyValue;

/**
 *  激活表字段属性
 *
 *  @return 表字段属性数组
 */
+ (NSArray<PFMDBTableProperty *> *)p_activateProperties;

@end
