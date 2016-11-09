//
//  ViewController.m
//  PFMDB
//
//  Created by hzw598 on 2016/11/8.
//  Copyright © 2016年 dg11185. All rights reserved.
//

#import "ViewController.h"
#import "Student.h"
#import "PFMDB.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Student *student = [[Student alloc] init];
    student.incrementId = @1;
    student.ids = 1;
    student.name = @"hzw598";
    student.age = 18;
    student.schoolName = @"中华大学";
    student.sex = kUserSexTypeMale;
    [student p_save];
    
    long total = [Student p_queryTotalCount];
    NSLog(@"total = %ld", total);
    
    NSArray *students = [Student p_queryByPage:0 pageSize:10];
    NSLog(@"students = %zd", students.count);
    
    if (students.count > 0) {
        Student *stu = [students objectAtIndex:0];
        NSLog(@"stu = %@", [stu p_toDictionry]);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
