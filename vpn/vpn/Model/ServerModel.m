//
//  ServerModel.m
//  vpn
//
//  Created by 戴特长 on 16/9/30.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import "ServerModel.h"

@implementation ServerModel
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    
    if((self = [super init])) {
        self.serverIp        = dict[@"ip"];
        self.serverName      = dict[@"name"];
    }
    return self;
}


@end

@implementation ServerList

- (instancetype)initWithArray:(NSArray *)array {
    if (self = [super init]) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in array) {
            ServerModel *m = [[ServerModel alloc] initWithDictionary:dict];
            [list addObject:m];
        }
        
        self.list = list;
        
    }
    
    return self;
}


@end

