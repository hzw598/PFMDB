//
//  PFMDBClassProtocol.h
//  PFMDB
//
//  Created by 周爱林 on 16/10/20.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PFMDBClassProtocol <NSObject>

@optional
/**
 *  获取类名
 *
 *  @return 类名
 */
+ (NSString *)p_className;

/**
 *  获取类属性
 *
 *  @return 类属性
 */
+ (NSArray *)p_properties;


/**
 *  获取键值对信息
 *
 *  @return 键值对
 */
- (NSDictionary *)p_toDictionry;


@end
