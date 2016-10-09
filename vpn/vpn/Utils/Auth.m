//
//  Auth.m
//  vpn
//
//  Created by 戴特长 on 16/9/26.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import "Auth.h"

@implementation Auth
+(NSString*)getUDID
{
    NSString *u = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    if(!u)
    {
        u = [MCSMApplicationUUIDKeychainItem applicationUUID];
        [[NSUserDefaults standardUserDefaults] setObject:u forKey:@"userId"];
    }
    return u;
}
@end
