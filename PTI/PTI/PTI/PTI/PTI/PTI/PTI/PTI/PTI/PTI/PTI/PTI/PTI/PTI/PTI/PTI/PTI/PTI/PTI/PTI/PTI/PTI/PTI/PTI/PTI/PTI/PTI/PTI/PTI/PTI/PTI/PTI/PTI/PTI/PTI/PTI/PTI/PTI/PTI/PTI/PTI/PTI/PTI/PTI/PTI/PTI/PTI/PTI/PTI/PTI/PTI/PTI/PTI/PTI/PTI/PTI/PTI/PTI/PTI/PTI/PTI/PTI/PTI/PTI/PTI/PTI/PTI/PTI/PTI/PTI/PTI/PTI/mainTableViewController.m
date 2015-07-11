//
//  mainTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "mainTableViewController.h"
#import "MySingleton.h"

@interface mainTableViewController ()

@end

NSMutableData *responseData;
NSString *web_service_type_request;

@implementation mainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //UIBarButtonItem *unAuthButton = [[UIBarButtonItem alloc] initWithTitle:@"Выйти" style:UIBarButtonItemStylePlain target:self action:@selector(refreshPropertyList:)];
    //self.navigationItem.leftBarButtonItem = unAuthButton;
    //UIBarButtonItem *unAuthButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"key_image"] style:UIBarButtonItemStylePlain target:self action:@selector(buttonOnePressed:)];
    // self.navigationItem.leftBarButtonItem = unAuthButton;
    
    
    //[[[MySingleton sharedManager] userID] isEqual:@"0"]
    
   // NSLog(@"%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"]);
    
    
    web_service_type_request = @"";
    
    
    
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"] == 0) {
        
        
        [UIView setAnimationsEnabled:NO];
        self.view.hidden = YES;
        
        [self performSegueWithIdentifier:@"gologin" sender:nil];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView setAnimationsEnabled:YES];
            self.view.hidden = NO;
        });
        
        
    }
    else {
       
        
        
        [self check_update];//ПОТОМ УБРАТЬ ЭТО СТРОЧКУ!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
        
       
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"last_db_check_update"] doubleValue] + (24 * 60 * 60 * 1000) <  [[NSDate date] timeIntervalSince1970]*1000) {
            
            
            /* Save current timestamp for next Check*/
            [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970]*1000 forKey:@"last_db_check_update"];
            
            /* Start Update */
            [self check_update];
        }
        
        
        
    }
    
    
    
    //[[MySingleton sharedManager] setUserID:@"1234"];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] userID]);

    
}




- (void)getUpdate
{
    NSURL *aUrl = [NSURL URLWithString:[[MySingleton sharedManager] url_webservice]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"cmd=sync_products_table";
    web_service_type_request = @"sync_products_table";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    
    responseData = [[NSMutableData alloc] init];
    
    
}


- (void)check_update
{
    NSURL *aUrl = [NSURL URLWithString:[[MySingleton sharedManager] url_webservice]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = @"cmd=sync_check_update";
    web_service_type_request = @"sync_check_update";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    
    responseData = [[NSMutableData alloc] init];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
    
    if([web_service_type_request  isEqual: @"sync_products_table"]) {
        
        
        
        
        
        NSLog(@"Response from webservice: %@", JSON);
    }
    
    if([web_service_type_request  isEqual: @"sync_check_update"]) {
        
        
        
        if ([[[JSON objectForKey:@"success"] stringValue]  isEqual: @"1"] && ![[JSON objectForKey:@"need_update"] isEqual:[[NSUserDefaults standardUserDefaults] stringForKey:@"last_db_update_time"]])//
        {
            [[NSUserDefaults standardUserDefaults] setValue:[JSON objectForKey:@"need_update"] forKey:@"last_db_update_time"];
            [[NSUserDefaults standardUserDefaults] synchronize];
           //NSLog(@"need update");
            [self getUpdate];
        }
       
        //NSLog(@"Response from webservice: %@", resp_success);
    }
    
}






- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
