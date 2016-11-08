//
//  User.h
//  PFMDB
//
//  Created by 周爱林 on 16/10/25.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UserSexType) {
    kUserSexTypeFemale = 0,
    kUserSexTypeMale,
};

@interface User : NSObject

@property (nonatomic) NSInteger ids;
@property (nonatomic, copy) NSString *name;
@property (nonatomic) UserSexType sex;
@property (nonatomic) NSInteger age;

@end
