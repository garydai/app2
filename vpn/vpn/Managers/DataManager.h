//
//  DataManager.h
//  AppFrame
//
//  Created by 戴特长 on 15/8/25.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#ifndef AppFrame_DataManager_h
#define AppFrame_DataManager_h

#import <Foundation/Foundation.h>
#import "ServerModel.h"
@interface DataManager : NSObject

+ (instancetype)manager;

- (void )addUser:(__weak UIViewController*)controller postParams:(NSDictionary*)params
              success:(void (^)())success
              failure:(void (^)())failure;


- (void )getUser:(UIViewController *__weak)controller postParams:(NSDictionary *)params success:(void (^)(UserModel *))success failure:(void (^)())failure;

- (void )getServer:(UIViewController *__weak)controller postParams:(NSDictionary *)params success:(void (^)(ServerList *,UserModel *))success failure:(void (^)())failure;

@end



#endif
