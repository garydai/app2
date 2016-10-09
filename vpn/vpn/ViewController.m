//
//  ViewController.m
//  vpn
//
//  Created by 戴特长 on 16/9/18.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import "ViewController.h"
#import <NetworkExtension/NetworkExtension.h>
#import "VCIPsecVPNManager.h"

@interface ViewController ()
@property (nonatomic) VCIPsecVPNManager * vpnmanager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.vpnmanager prepareWithCompletion:^(NSError *error) {
       // self.isPrepareProfile = NO;
        
       
           // [self.vpnmanager connectIPSecIKEv2WithHost:@"domain.com" andUsername:@"gaga" andPassword:@"123456" andPSK:[[VPNStations sharedInstance].config valueForKey:@"psk"] andGroupName:[[VPNStations sharedInstance].config valueForKey:@"groupname"]];
        
        
     
        
    }];

    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
