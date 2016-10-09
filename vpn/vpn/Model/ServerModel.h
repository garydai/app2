//
//  ServerModel.h
//  vpn
//
//  Created by 戴特长 on 16/9/30.
//  Copyright © 2016年 gaga. All rights reserved.
//
#ifndef AppFrame_ServerModel_h
#define AppFrame_ServerModel_h


#import <Foundation/Foundation.h>

@interface ServerModel : NSObject
@property(nonatomic, strong) NSNumber *serverId;
@property (nonatomic, copy) NSString *serverIp;
@property(nonatomic, copy) NSString *serverName;

- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end


@interface ServerList : NSObject
@property(nonatomic, strong) NSArray *list;
- (instancetype)initWithArray:(NSArray *)array;

@end

#endif
