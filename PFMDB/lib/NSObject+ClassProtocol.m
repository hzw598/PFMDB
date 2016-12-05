//
//  NSObject+ClassProtocol.m
//  PFMDB
//
//  Created by hzw598 on 16/10/25.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "NSObject+ClassProtocol.h"
#import <objc/runtime.h>
#import "PFMDBObjcProperty.h"

@implementation NSObject (ClassProtocol)

/**
 *  获取类名
 *
 *  @return 类名
 */
+ (NSString *)p_className {
    return NSStringFromClass([self class]);
}

/**
 *  获取类属性
 *
 *  @return 类属性
 */
+ (NSArray *)p_properties {
    unsigned int count;
    objc_property_t *props = class_copyPropertyList([self class], &count);
    NSMutableArray *array = [NSMutableArray array];
    
    //过滤系统属性
    NSArray *filters = @[@"superclass", @"description", @"debugDescription", @"hash"];
    
    for (int i=0; i<count; i++) {
        objc_property_t prop = props[i];
        //过滤系统属性
        NSString *key = [NSString stringWithUTF8String:property_getName(prop)];
        if ([filters containsObject:key]) {
            continue;
        }
        
        PFMDBObjcProperty *objcProp = [[PFMDBObjcProperty alloc] initWithProperty:prop];
        [array addObject:objcProp];
    }
    
    free(props);
    
    Class superClass = [self superclass];
    NSString *superClassStr = NSStringFromClass(superClass);
    if (![superClassStr isEqualToString:@"NSObject"]) {
        [array addObjectsFromArray:[superClass p_properties]];
    }
    
    return array;
}


/**
 *  获取键值对信息
 *
 *  @return 键值对
 */
- (NSDictionary *)p_toDictionry {
    
    NSArray<PFMDBObjcProperty *> *objcProps = [[self class] p_properties];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [objcProps enumerateObjectsUsingBlock:^(PFMDBObjcProperty *obj, NSUInteger idx, BOOL *stop) {
        id value = [self valueForKey:obj.name];
        if (!value) {
            value = [NSNull null];
        }
        [dict setObject:value forKey:obj.name];
    }];
    
    return dict;
}

@end
