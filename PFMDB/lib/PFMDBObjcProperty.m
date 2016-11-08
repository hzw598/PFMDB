//
//  PFMDBObjcProperty.m
//  PFMDB
//
//  Created by 周爱林 on 16/10/21.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "PFMDBObjcProperty.h"

@implementation PFMDBObjcProperty

/**
 *  初始化方法
 *
 *  @param prop 运行时属性对象
 *
 *  @return OBJCProperty
 */
- (instancetype)initWithProperty:(objc_property_t)prop
{
    self = [super init];
    
    if (self) {
        _name = [self utf8ToString:property_getName(prop)];
        
        unsigned int outCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(prop, &outCount);
        for (int i = 0; i < outCount; i++) {
            objc_property_attribute_t attr = attrs[i];
            NSString *attrName = [self utf8ToString:attr.name];
            NSString *attrValue = [self utf8ToString:attr.value];
            if ([attrName isEqualToString:@"V"]) {
                _ivar = attrValue;
            } else if ([attrName isEqualToString:@"T"]) {
                _type = attrValue;
            }
        }
        free(attrs);
    }
    
    return self;
}

//将char转化为NSString
- (NSString *)utf8ToString:(const char *)utf8String {
    if (!utf8String) {
        return nil;
    }
    
    return [NSString stringWithUTF8String:utf8String];
}

@end
