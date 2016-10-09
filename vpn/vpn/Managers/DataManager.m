//
//  DataManager.m
//  AppFrame
//
//  Created by 戴特长 on 15/8/25.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataManager.h"


@interface DataManager ()



@end

@implementation DataManager


+ (instancetype)manager {
    static DataManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataManager alloc] init];
    });
    return manager;
}


- (void )addUser:(UIViewController *__weak)controller postParams:(NSDictionary *)params success:(void (^)())success failure:(void (^)())failure
{
    [Http request:controller api:API_ADD_USER params:params success:success fail:failure];
    
}

- (void )getUser:(UIViewController *__weak)controller postParams:(NSDictionary *)params success:(void (^)(UserModel *))success failure:(void (^)())failure
{
    [Http request:controller api:API_GET_USER params:params success:^(id responseObject, HttpRequest *operation)
     {
         UserModel *model = [[UserModel alloc] initWithDictionary:responseObject];
         success(model);
     }
             fail:failure];
    
}


- (void )getServer:(UIViewController *__weak)controller postParams:(NSDictionary *)params success:(void (^)(ServerList *, UserModel *))success failure:(void (^)())failure
{
    [Http request:controller api:API_GET_SERVER params:params success:^(id responseObject, HttpRequest *operation)
     {
         ServerList *model = [[ServerList alloc] initWithArray:responseObject[@"server"]];
         UserModel *user =  [[UserModel alloc] initWithDictionary:responseObject[@"user"]];
         success(model, user);
         
     }fail:failure];
    
}


@end
