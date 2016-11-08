//
//  PFMDBObjcToTableUtil.h
//  PFMDB
//
//  Created by 周爱林 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFMDBTableProperty;
@class PFMDBObjcProperty;

@interface PFMDBObjcToTableUtil : NSObject

/**
 *  将objc属性转化为db类型
 *
 *  @param proArray objc属性数组
 *
 *  @return db属性数组
 */
+ (NSArray<PFMDBTableProperty *> *)changeToDbByObjcProperties:(NSArray<PFMDBObjcProperty *> *)proArray;

/**
 *  将objc的类型转化为db表类型
 *
 *  @param objcType objc类型
 *
 *  @return db表类型
 */
+ (NSString *)changeToDbTypeByObjcType:(NSString *)objcType;

@end
