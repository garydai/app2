//
//  ServerListViewController.h
//  vpn
//
//  Created by 戴特长 on 16/9/30.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerListViewController : UITableViewController
@property(nonatomic, strong) NSArray *serverList;
@property(nonatomic, copy) void(^selectServer)(NSInteger index);
@property(nonatomic, assign) NSInteger index;
@end
