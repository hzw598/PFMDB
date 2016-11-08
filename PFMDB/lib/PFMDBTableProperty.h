//
//  PFMDBTableProperty.h
//  PFMDB
//  表字段属性
//  Created by 周爱林 on 16/10/20.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, PFMDBDataType) {
    PFMDBDataTypeInt = 1,
    PFMDBDataTypeLong,
    PFMDBDataTypeULong,
    PFMDBDataTypeDouble,
    PFMDBDataTypeString,
    PFMDBDataTypeNSNumber,
    PFMDBDataTypeNSData,
    PFMDBDataTypeNSDate,

    PFMDBDataTypeUnsupport,
};

@interface PFMDBTableProperty : NSObject

@property (nonatomic, copy) NSString *name;//数据表字段名
@property (nonatomic, copy) NSString *type;//数据表字段类型
@property (nonatomic, copy) NSString *databaseName;//数据库名
@property (nonatomic, copy) NSString *tableName;//表名
@property (nonatomic) PFMDBDataType dataType;

@end
