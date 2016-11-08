//
//  PFMDBObjcToTableUtil.m
//  PFMDB
//
//  Created by 周爱林 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "PFMDBObjcToTableUtil.h"
#import "PFMDBObjcProperty.h"
#import "PFMDBTableProperty.h"

@implementation PFMDBObjcToTableUtil

/**
 *  将objc属性转化为db类型
 *
 *  @param proArray objc属性数组
 *
 *  @return db属性数组
 */
+ (NSArray<PFMDBTableProperty *> *)changeToDbByObjcProperties:(NSArray<PFMDBObjcProperty *> *)proArray {
    if (!proArray) {
        return nil;
    }
    
    NSMutableArray *dbProperties = [NSMutableArray array];
    [proArray enumerateObjectsUsingBlock:^(PFMDBObjcProperty *obj, NSUInteger idx, BOOL *stop) {
        PFMDBTableProperty *dbProperty = [[PFMDBTableProperty alloc] init];
        dbProperty.name = obj.name;
        dbProperty.type = [self changeToDbTypeByObjcType:obj.type];
        dbProperty.dataType = [self changeToDataTypeByObjcType:obj.type];
        [dbProperties addObject:dbProperty];
    }];
    
    return dbProperties;
}

/**
 *  将objc的类型转化为db表类型
 *
 *  @param objcType objc类型
 *
 *  @return db表类型
 */
+ (NSString *)changeToDbTypeByObjcType:(NSString *)objcType {
    if ([objcType isEqualToString:[NSString stringWithUTF8String:@encode(int)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(unsigned int)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(long)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(unsigned long)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(BOOL)]]
        ) {
        return @"INTEGER";
    }
    if ([objcType isEqualToString:[NSString stringWithUTF8String:@encode(float)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(double)]]
        ) {
        return @"REAL";
    }
    if ([objcType rangeOfString:@"String"].length) {
        return @"TEXT";
    }
    if ([objcType rangeOfString:@"NSNumber"].length) {
        return @"REAL";
    }
    if ([objcType rangeOfString:@"NSData"].length) {
        return @"BLOB";
    }
    if ([objcType rangeOfString:@"NSDate"].length) {
        return @"DATETIME";
    }
    return nil;
}

/**
 *  将objc的类型转化为自定义DataType类型
 *
 *  @param objcType objc类型
 *
 *  @return 自定义DataType类型
 */
+ (PFMDBDataType)changeToDataTypeByObjcType:(NSString *)objcType {
    if ([objcType isEqualToString:[NSString stringWithUTF8String:@encode(int)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(BOOL)]]
        ||[objcType isEqualToString:[NSString stringWithUTF8String:@encode(unsigned int)]]) {
        return PFMDBDataTypeInt;
    }
    if ([objcType isEqualToString:[NSString stringWithUTF8String:@encode(long)]]) {
        return PFMDBDataTypeLong;
    }
    if ([objcType isEqualToString:[NSString stringWithUTF8String:@encode(float)]] || [objcType isEqualToString:[NSString stringWithUTF8String:@encode(double)]]) {
        return PFMDBDataTypeDouble;
    }
    if ([objcType rangeOfString:@"String"].length) {
        return PFMDBDataTypeString;
    }
    if ([objcType rangeOfString:@"NSNumber"].length) {
        return PFMDBDataTypeNSNumber;
    }
    if ([objcType rangeOfString:@"NSData"].length) {
        return PFMDBDataTypeNSData;
    }
    if ([objcType rangeOfString:@"NSDate"].length) {
        return PFMDBDataTypeNSDate;
    }
    return PFMDBDataTypeUnsupport;
}

@end
