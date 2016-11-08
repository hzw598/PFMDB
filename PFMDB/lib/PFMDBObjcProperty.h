//
//  PFMDBObjcProperty.h
//  PFMDB
//
//  Created by hzw598 on 16/10/21.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface PFMDBObjcProperty : NSObject

/**
 *  初始化方法
 *
 *  @param prop 运行时属性对象
 *
 *  @return PFMDBObjcProperty
 */
- (instancetype)initWithProperty:(objc_property_t)prop;

@property (nonatomic, copy, readonly) NSString *name;//属性名
@property (nonatomic, copy, readonly) NSString *type;//属性类型
@property (nonatomic, copy, readonly) NSString *ivar;//变量名（ivar=_name）



@end
