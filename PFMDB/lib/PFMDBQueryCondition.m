//
//  PFMDBQueryCondition.m
//  PFMDB
//
//  Created by hzw598 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "PFMDBQueryCondition.h"

@implementation PFMDBQueryCondition

/**
 *  条件查询初始化方法
 *
 *  @param conditions 条件语句，如：@"name = ?"、@"name like ?"、@"name=? or name=?"
 *  @param argvs      @[@"11"]
 *
 *  @return instancetype
 */
+ (instancetype)conditions:(NSString *)conditions argvs:(NSArray *)argvs
{
    PFMDBQueryCondition *condition = [[PFMDBQueryCondition alloc] init];
    condition->_conditions = conditions;
    condition->_argvs = argvs;
    
    return condition;
}

@end
