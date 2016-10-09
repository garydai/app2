//
//  UserModel.m
//  AppFrame
//
//  Created by 戴特长 on 15/7/31.
//  Copyright (c) 2015年 Huizhe. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel


- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    if((self = [super init])) {
        self.userName        = dict[@"username"];
        self.dstTime         = dict[@"dsttime"];
    }
    return self;
}




@end
