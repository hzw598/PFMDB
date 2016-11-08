//
//  PFMDBQueryCondition.h
//  PFMDB
//  条件查询参数值
//  Created by hzw598 on 16/10/24.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PFMDBQueryCondition : NSObject

@property (nonatomic, copy, readonly) NSString *conditions;//条件语句
@property (nonatomic, copy, readonly) NSArray *argvs;//参数值

/**
 *  条件查询初始化方法
 *
 *  @param conditions 条件语句，如：@"name = ?"、@"name like ?"、@"name=? or name=?"
 *  @param argvs      @[@"11"]
 *
 *  @return instancetype
 */
+ (instancetype)conditions:(NSString *)conditions argvs:(NSArray *)argvs;

@end
