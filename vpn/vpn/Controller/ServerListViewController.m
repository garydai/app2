//
//  ServerListViewController.m
//  vpn
//
//  Created by 戴特长 on 16/9/30.
//  Copyright © 2016年 gaga. All rights reserved.
//

#import "ServerListViewController.h"
#define kCellIdentifier_list @"listViewControllerCellIdentifier"
@interface ServerListViewController ()

@end

@implementation ServerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"服务器列表";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier_list];
    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = YES;
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
   // self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getServer];
}
-(void)getServer
{
    [SVProgressHUD show];
    [[DataManager manager] getServer:self postParams:@{@"userid":[Auth getUDID]} success:^(ServerList *m, UserModel *user)
     {
         [SVProgressHUD dismiss];
         if(m)
         {
             _serverList = m.list;
            [self.tableView reloadData];
         }
         
     } failure:^(){[SVProgressHUD showWithStatus:@"获取服务器列表失败"];}];
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
    if(_serverList)
        return _serverList.count;
    else return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier_list forIndexPath:indexPath];
    cell.textLabel.text = ((ServerModel*)_serverList[indexPath.row]).serverName;
    if([_serverModel.serverName isEqualToString: ((ServerModel*)_serverList[indexPath.row]).serverName])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(_selectServer)
    {
        _selectServer((ServerModel*)_serverList[indexPath.row]);
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

@end
