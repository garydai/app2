//
//  HomeViewController.m
//  vpn
//
//  Created by 戴特长 on 16/9/18.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import "HomeViewController.h"
#import <NetworkExtension/NEVPNManager.h>
#import <NetworkExtension/NEVPNConnection.h>
#import <NetworkExtension/NEVPNProtocolIKEv2.h>
#import "ServerListViewController.h"
#import "VIPListViewController.h"
#define kCellIdentifier_home @"homeViewControllerCellIdentifier"
@interface HomeViewController ()
@property(strong, nonatomic) NEVPNManager *vpnManager;
@property(strong, nonatomic) UIButton *connectBtn;
@property(strong, nonatomic) NSArray *serverArray;
@property(assign, nonatomic) NSInteger index;
@property(strong, nonatomic) UserModel *userModel;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_home];
    self.title = @"vpn";
    self.tableView.tableFooterView=[self customFooterView];
    self.clearsSelectionOnViewWillAppear = YES;
    self.vpnManager = [NEVPNManager sharedManager];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(vpnStatusDidChanged:)
               name:NEVPNStatusDidChangeNotification
             object:nil];

    _serverArray = [[NSArray alloc] init];
    _index = 0;
    [self getServer];
   // [self loadData];
}


-(void)getServer
{
    [SVProgressHUD show];
    [[DataManager manager] getServer:self postParams:@{@"userid":[Auth getUDID]} success:^(ServerList *m, UserModel *user)
     {
         [SVProgressHUD dismiss];
         if(m)
         {
             _serverArray = m.list;
             _userModel = user;
            [self.tableView reloadData];
         }
         
     } failure:^(){[SVProgressHUD showWithStatus:@"获取服务器列表失败"];}];
}

- (UIView *)customFooterView{
    UIView *footerV     = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 150)];
    _connectBtn = [UIButton buttonWithStyle:blueStyle andTitle:@"连接" andFrame:CGRectMake(30, 50, kScreenWidth -30*2, 45) target:self action:@selector(changeVPNStatus)];
    [footerV addSubview:_connectBtn];
    
    
    return footerV;
    
}

-(void)installProfile{
    
    [self createKeychainValue:@"gagatechang" forIdentifier:@"VPN_PASSWORD"];
    
    // Load config from perference
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"Load config failed [%@]", error.localizedDescription);
            return;
        }
        
        NEVPNProtocolIKEv2 *p = (NEVPNProtocolIKEv2 *)_vpnManager.protocolConfiguration;
        
        if (p) {
            // Protocol exists.
            // If you don't want to edit it, just return here.
        } else {
            // create a new one.
            p = [[NEVPNProtocolIKEv2 alloc] init];
        }
        
        // config IPSec protocol
        p.username = [Auth getUDID];
       // p.serverAddress = @"47.88.149.225";
       // NSLog(@"%@", ((ServerModel*)_serverArray[_index]).serverIp);
        p.serverAddress = ((ServerModel*)_serverArray[_index]).serverIp;
        // Get password persistent reference from keychain
        // If password doesn't exist in keychain, should create it beforehand.
        // [self createKeychainValue:@"your_password" forIdentifier:@"VPN_PASSWORD"];
        p.passwordReference = [self searchKeychainCopyMatching:@"VPN_PASSWORD"];
        
        // PSK
          p.authenticationMethod = NEVPNIKEAuthenticationMethodSharedSecret;
         [self createKeychainValue:@"123456" forIdentifier:@"PSK"];
          p.sharedSecretReference = [self searchKeychainCopyMatching:@"PSK"];
        //p.authenticationMethod =   NEVPNIKEAuthenticationMethodCertificate;
        /*
         // certificate
         p.identityData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"client" ofType:@"p12"]];
         p.identityDataPassword = @"[Your certificate import password]";
         */
        
      //  p.localIdentifier = @"47.88.149.225";
     //   p.remoteIdentifier = @"47.88.149.225";
        p.remoteIdentifier = ((ServerModel*)_serverArray[_index]).serverIp;
        p.useExtendedAuthentication = YES;
        p.disconnectOnSleep = NO;
        
        _vpnManager.protocolConfiguration = p;
        _vpnManager.localizedDescription = @"feifeiVPN";
        _vpnManager.enabled = YES;
        
        [_vpnManager saveToPreferencesWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Save config failed [%@]", error.localizedDescription);
            }
        }];
    }];
    
    
}

- (void)connect {
   // [[DataManager manager] addUser:nil postParams:@{@"userid":@"test"} success:nil failure:nil];
    //return ;
    
    // Install profile
    [self installProfile];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(vpnConfigDidChanged:)
               name:NEVPNConfigurationChangeNotification
             object:nil];
    
}


- (void)vpnConfigDidChanged:(NSNotification *)notification
{
    // TODO: Save configuration failed
    [self startConnecting];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NEVPNConfigurationChangeNotification
                                                  object:nil];
}

- (void)startConnecting
{
    NSError *startError;
    [_vpnManager.connection startVPNTunnelAndReturnError:&startError];
    if (startError) {
        NSLog(@"Start VPN failed: [%@]", startError.localizedDescription);
    }
}


- (void)changeVPNStatus
{
    NEVPNStatus status = _vpnManager.connection.status;
    if (status == NEVPNStatusConnected
        || status == NEVPNStatusConnecting
        || status == NEVPNStatusReasserting) {
        [self disconnect];
    } else {
        [self connect];
    }
}



- (void)disconnect
{
    [_vpnManager.connection stopVPNTunnel];
}

- (void)vpnStatusDidChanged:(NSNotification *)notification
{
    NEVPNStatus status = _vpnManager.connection.status;
    switch (status) {
        case NEVPNStatusConnected:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
         //   _activityIndicator.hidden = YES;
            break;
        case NEVPNStatusInvalid:
        case NEVPNStatusDisconnected:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"连接" forState:UIControlStateNormal];
          //  _activityIndicator.hidden = YES;
            break;
        case NEVPNStatusConnecting:
        case NEVPNStatusReasserting:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"连接中..." forState:UIControlStateNormal];
          //  _activityIndicator.hidden = NO;
          //  [_activityIndicator startAnimating];
            break;
        case NEVPNStatusDisconnecting:
            _connectBtn.enabled = NO;
            [_connectBtn setTitle:@"断开连接中..." forState:UIControlStateDisabled];
           // _activityIndicator.hidden = NO;
          //  [_activityIndicator startAnimating];
            break;
        default:
            break;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_home ];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier_home];
    }
    
    if(indexPath.row == 0)
    {
        cell.textLabel.text = @"用户";
        cell.detailTextLabel.text = [MCSMApplicationUUIDKeychainItem applicationUUID];
        
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = @"类型";
        cell.detailTextLabel.text = @"ikev2";
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = @"切换地区";
        if(_serverArray.count > 0)
            cell.detailTextLabel.text = ((ServerModel*)_serverArray[_index]).serverName;
        else
            cell.detailTextLabel.text = @"";
    }
    else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"有效期至";
        cell.detailTextLabel.text = _userModel.dstTime;
    }
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        if(_serverArray.count > 0)
        {
            ServerListViewController *serverList = [[ServerListViewController alloc] init];
            serverList.serverList = _serverArray;
            serverList.index = _index;
            serverList.selectServer = ^(NSInteger index)
            {
                _index = index;
                [self.navigationController popViewControllerAnimated:YES];
                [self.tableView reloadData];
            };
            [self.navigationController pushViewController:serverList animated:YES];
        }
    }
    else if(indexPath.row == 3)
    {
        
    }
    else if(indexPath.row == 4)
    {
        VIPListViewController *vc = [[VIPListViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - KeyChain

static NSString * const serviceName = @"im.zorro.ipsec_demo.vpn_config";

- (NSMutableDictionary *)newSearchDictionary:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [[NSMutableDictionary alloc] init];
    
    [searchDictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    NSData *encodedIdentifier = [identifier dataUsingEncoding:NSUTF8StringEncoding];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrGeneric];
    [searchDictionary setObject:encodedIdentifier forKey:(__bridge id)kSecAttrAccount];
    [searchDictionary setObject:serviceName forKey:(__bridge id)kSecAttrService];
    
    return searchDictionary;
}

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier {
    NSMutableDictionary *searchDictionary = [self newSearchDictionary:identifier];
    
    // Add search attributes
    [searchDictionary setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    
    // Add search return types
    // Must be persistent ref !!!!
    [searchDictionary setObject:@YES forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef result = NULL;
    SecItemCopyMatching((__bridge CFDictionaryRef)searchDictionary, &result);
    
    return (__bridge_transfer NSData *)result;
}

- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier {
    NSMutableDictionary *dictionary = [self newSearchDictionary:identifier];
    
    OSStatus status = SecItemDelete((__bridge CFDictionaryRef)dictionary);
    
    NSData *passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
    [dictionary setObject:passwordData forKey:(__bridge id)kSecValueData];
    
    status = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);
    
    if (status == errSecSuccess) {
        return YES;
    }
    return NO;
}

@end
