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
//#import "JOYConnect.h"
#define kCellIdentifier_home @"homeViewControllerCellIdentifier"
@import GoogleMobileAds;
@interface HomeViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property(strong, nonatomic) NEVPNManager *vpnManager;
@property(strong, nonatomic) UIButton *connectBtn;
@property(strong, nonatomic) NSArray *serverArray;
@property(assign, nonatomic) NSInteger index;
@property(strong, nonatomic) UserModel *userModel;
@property(strong, nonatomic) ServerModel *serverModel;
@property(strong, nonatomic) GADBannerView *bannerView;
@property (strong, nonatomic) UILabel *noticeLabel;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
   // [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_home];
    self.title = @"飞飞";
    self.tableView.tableFooterView=[self customFooterView];
    self.clearsSelectionOnViewWillAppear = YES;
    self.vpnManager = [NEVPNManager sharedManager];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
   // [self installProfile];
    [nc addObserver:self
           selector:@selector(vpnStatusDidChanged:)
               name:NEVPNStatusDidChangeNotification
             object:nil];
    [_vpnManager loadFromPreferencesWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Load config failed [%@]", error.localizedDescription);
           // return;
        }
        
       // NEVPNProtocolIKEv2 *p = (NEVPNProtocolIKEv2 *)_vpnManager.protocolConfiguration;
        
    }];
   // [self checkVPNStatus];
    
    _serverArray = [[NSArray alloc] init];
    _index = 0;
    [self uploadUserId];
   // [JOYConnect showBan:self adSize:E_SIZE_768X90 showX:0 showY:kScreenHeight - kNavHeight - 45];
    
   // [self loadData];
    self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavHeight - 50, kScreenWidth, 50)];
    [self.view addSubview:_bannerView];
    self.bannerView.adUnitID = @"ca-app-pub-7576129819707438/2999156101";
    self.bannerView.rootViewController = self;
    [self.bannerView loadRequest:[GADRequest request]];
    self.noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kScreenHeight - kNavHeight - 100, kScreenWidth, 50)];
    _noticeLabel.textAlignment = NSTextAlignmentCenter;
    _noticeLabel.textColor = gBlueColor;
    _noticeLabel.text = @"反馈，不能用呀！";
    _noticeLabel.font = [UIFont systemFontOfSize:14];
    _noticeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(report)];
    [_noticeLabel addGestureRecognizer:labelTapGestureRecognizer];
    [self.view addSubview:_noticeLabel];
}

-(void)report
{
    [[DataManager manager] report:self postParams:@{@"userid":[Auth getUDID]} success:
     ^(){
         [SVProgressHUD showInfoWithStatus:@"发送成功"];
     }
                          failure:^(){
                              [SVProgressHUD showInfoWithStatus:@"发送失败"];
                          }];
}

/*
- (void)onBannerShow
{
    NSLog(@"     ");
}
- (void)onBannerShowFailed:(NSString *)error
{
    NSLog(@"       :%@",error);
}
- (void)onBannerClick
{
    NSLog(@"     ");
}
- (void)onBannerClose
{
    [JOYConnect closeBan];
}
 */


-(void)uploadUserId
{
    NSString *userId = [Auth getUDID];
    if(userId)
    {
        [SVProgressHUD show];
        [[DataManager manager] addUser:self postParams:@{@"userid":userId} success:^()
         {
             [[DataManager manager] getServer:self postParams:@{@"userid":userId} success:^(ServerList *m, UserModel *user)
              {
                  [SVProgressHUD dismiss];
                  if(m)
                  {
                      _serverArray = m.list;
                      _userModel = user;
                      // int i = arc4random() % m.list.count ;
                      _serverModel = _serverArray[0];
                      [self.tableView reloadData];
                  }
                  
              } failure:^(){[SVProgressHUD showInfoWithStatus:@"获取服务器列表失败"];}];
             
         }
            failure:^(){
            
            [SVProgressHUD showInfoWithStatus:@"上传用户失败"];
        }];
    }
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
            // int i = arc4random() % m.list.count ;
             _serverModel = _serverArray[0];
            [self.tableView reloadData];
         }
       
     } failure:^(){[SVProgressHUD showInfoWithStatus:@"获取服务器列表失败"];}];
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
          //  return ;
        } else {
            // create a new one.
            p = [[NEVPNProtocolIKEv2 alloc] init];
        }
        
        // config IPSec protocol
        p.username = [Auth getUDID];
       // p.serverAddress = @"47.88.149.225";
       // NSLog(@"%@", ((ServerModel*)_serverArray[_index]).serverIp);
        p.serverAddress = _serverModel.serverIp;
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
        p.remoteIdentifier = _serverModel.serverIp;
        p.useExtendedAuthentication = YES;
        p.disconnectOnSleep = NO;
        
        _vpnManager.protocolConfiguration = p;
        _vpnManager.localizedDescription = @"飞飞VPN";
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


-(void)checkVPNStatus
{
    NEVPNStatus status = _vpnManager.connection.status;
    switch (status) {
        case NEVPNStatusConnected:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"断开连接" forState:UIControlStateNormal];
            //   _activityIndicator.hidden = YES;
            break;
        case NEVPNStatusInvalid:
            //[self disconnect];
        case NEVPNStatusDisconnected:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"连接" forState:UIControlStateNormal];
            //  _activityIndicator.hidden = YES;
            break;
        case NEVPNStatusConnecting:
        case NEVPNStatusReasserting:
            _connectBtn.enabled = YES;
            [_connectBtn setTitle:@"连接中...（如果连接失败，请再连一次）" forState:UIControlStateNormal];
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
- (void)changeVPNStatus
{
    NEVPNStatus status = _vpnManager.connection.status;
    if (status == NEVPNStatusConnected
        || status == NEVPNStatusConnecting
        || status == NEVPNStatusReasserting) {
        [self disconnect];
    } else {
        [self connect];
        return ;
        [SVProgressHUD show];
        [[DataManager manager] getUser:self postParams:@{@"userid":[Auth getUDID]} success:^(UserModel *user) {
            
            [SVProgressHUD dismiss];
            if(user)
            {
                _userModel = user;
                [self.tableView reloadData];
                
                NSDate * date = [NSDate date];
                NSTimeInterval sec = [date timeIntervalSinceNow];
                NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
                NSDateFormatter * df = [[NSDateFormatter alloc] init ];
                [df setDateFormat:@"YYYY-MM-dd HH:MM"];
                NSString * na = [df stringFromDate:currentDate];
                if([na compare:user.dstTime]  == NSOrderedAscending)
                {
                     [self connect];
                }
                else
                {
                    [SVProgressHUD showInfoWithStatus:@"到期啦"];
                }
                
            }
 
            
        }failure:^(){}];
    }
}



- (void)disconnect
{
    [_vpnManager.connection stopVPNTunnel];
}

- (void)vpnStatusDidChanged:(NSNotification *)notification
{
    [self checkVPNStatus];
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
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_home ];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kCellIdentifier_home];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
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
        if(_serverModel)
            cell.detailTextLabel.text = _serverModel.serverName;
        else
            cell.detailTextLabel.text = @"";
    }
    else if(indexPath.row == 3)
    {
        cell.textLabel.text = @"有效期至";
        cell.detailTextLabel.text = _userModel.dstTime;
    }
    else if(indexPath.row == 4)
    {
        cell.textLabel.text = @"打赏";
        cell.detailTextLabel.text = @"¥6";
    }
    
    
    // Configure the cell...
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 2)
    {
        NEVPNStatus status = _vpnManager.connection.status;
        if (status == NEVPNStatusConnecting) {
            return ;
        }

        
        if(_serverArray.count > 0)
        {
            ServerListViewController *serverList = [[ServerListViewController alloc] init];
            serverList.serverList = _serverArray;
            serverList.serverModel = _serverModel;
            serverList.selectServer = ^(ServerModel *model)
            {
                _serverModel = model;
                [self.navigationController popViewControllerAnimated:YES];
                [self.tableView reloadData];
                NEVPNStatus status = _vpnManager.connection.status;
                if (status == NEVPNStatusConnected
                    || status == NEVPNStatusConnecting
                    || status == NEVPNStatusReasserting) {
                    [self disconnect];
                }
                
            };
            [self.navigationController pushViewController:serverList animated:YES];
        }
    }
    else if(indexPath.row == 4)
    {
        if([SKPaymentQueue canMakePayments]){
            [self requestProductData:@"dashan6"];
        }else{
            NSLog(@"不允许程序内付费");
        }
        
       // VIPListViewController *vc = [[VIPListViewController alloc] init];
        //[self.navigationController pushViewController:vc animated:YES];
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



//请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
    [SVProgressHUD show];
    //  [SVProgressHUD showWithStatus:nil maskType:SVProgressHUDMaskTypeBlack];
    
    NSArray *product = [[NSArray alloc] initWithObjects:type,nil];
    
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    //[SVProgressHUD dismiss];
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    if([product count] == 0){
        [SVProgressHUD dismiss];
        NSLog(@"--------------没有商品------------------");
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        //  if([pro.productIdentifier isEqualToString:_currentProId]){
        p = pro;
        //}
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
     [SVProgressHUD showErrorWithStatus:@"支付失败"];
    
    NSLog(@"------------------错误-----------------:%@", error);
}

- (void)requestDidFinish:(SKRequest *)request{
      [SVProgressHUD dismiss];
    NSLog(@"------------反馈信息结束-----------------");
}
//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
/**
 *  验证购买，避免越狱软件模拟苹果请求达到非法购买问题
 *
 */
-(void)verifyPurchaseWithPaymentTransaction{
    //从沙盒中获取交易凭证并且拼接成请求体数据
    NSURL *receiptUrl=[[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData=[NSData dataWithContentsOfURL:receiptUrl];
    
    NSString *receiptString=[receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];//转化为base64字符串
    
    NSString *bodyString = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", receiptString];//拼接请求数据
    NSData *bodyData = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //创建请求到苹果官方进行购买验证
    NSURL *url=[NSURL URLWithString:SANDBOX];
    NSMutableURLRequest *requestM=[NSMutableURLRequest requestWithURL:url];
    requestM.HTTPBody=bodyData;
    requestM.HTTPMethod=@"POST";
    //创建连接并发送同步请求
    NSError *error=nil;
    NSData *responseData=[NSURLConnection sendSynchronousRequest:requestM returningResponse:nil error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:@"购买失败"];
        NSLog(@"验证购买过程中发生错误，错误信息：%@",error.localizedDescription);
        return;
    }
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:nil];
    NSLog(@"%@",dic);
    if([dic[@"status"] intValue]==0){
        NSLog(@"购买成功！");
        NSDictionary *dicReceipt= dic[@"receipt"];
        NSDictionary *dicInApp=[dicReceipt[@"in_app"] firstObject];
        NSString *productIdentifier= dicInApp[@"product_id"];//读取产品标识
        //如果是消耗品则记录购买数量，非消耗品则记录是否购买过
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
     //   if ([productIdentifier isEqualToString:@"123"]) {
       //     int purchasedCount=[defaults integerForKey:productIdentifier];//已购买数量
         //   [[NSUserDefaults standardUserDefaults] setInteger:(purchasedCount+1) forKey:productIdentifier];
      //  }else{
        //    [defaults setBool:YES forKey:productIdentifier];
       // }
        if([productIdentifier isEqualToString:@"dashan6"])
        {
            [SVProgressHUD showWithStatus:@"谢谢支持"];
        }
        //在此处对购买记录进行存储，可以存储到开发商的服务器端
    }else{
         [SVProgressHUD showErrorWithStatus:@"购买失败"];
        NSLog(@"购买失败，未通过验证！");
    }
}
//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    
    for(SKPaymentTransaction *tran in transaction){
        
        
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                NSLog(@"交易完成");
                [self verifyPurchaseWithPaymentTransaction];
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
            }
                
                
                
                
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:{
                NSLog(@"已经购买过商品");
                
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
            }
                break;
            case SKPaymentTransactionStateFailed:{
                NSLog(@"交易失败");
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                [SVProgressHUD showErrorWithStatus:@"购买失败"];
            }
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}



@end
