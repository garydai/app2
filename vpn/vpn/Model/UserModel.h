//
//  UserModel.h
//  AppFrame
//
//  Created by 戴特长 on 15/7/31.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#ifndef AppFrame_UserModel_h
#define AppFrame_UserModel_h


#import <Foundation/Foundation.h>

@interface UserModel : NSObject 

@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, copy) NSString *userName, *dstTime;
- (instancetype)initWithDictionary:(NSDictionary *)dict ;
@end

#endif
