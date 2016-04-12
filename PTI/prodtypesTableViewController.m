//
//  prodtypesTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 11.07.15.
//  Copyright © 2015 ilab.pro LLC. All rights reserved.
//

#import "prodtypesTableViewController.h"
#import "MySingleton.h"
#import "MBProgressHUD.h"

#import "FMDB.h"
#import "ProductInfo.h"

@interface prodtypesTableViewController ()

@end
NSMutableData *responseData;
NSString *web_service_type_request;
MBProgressHUD *hud;
long long expectedLength;
long long currentLength;
NSDictionary *JSON;


NSArray *searchProductsArray;



@implementation prodtypesTableViewController
@synthesize writableDBPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
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
    
    [[MySingleton sharedManager] setSelected_product_name:@"all"];
    
    
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
        
        [self reloadProducts];
        
        
        
        
        
        
        
        
        
    }
    
    
    
    //[[MySingleton sharedManager] setUserID:@"1234"];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] userID]);
    
    
}
- (IBAction)exitAuth:(id)sender {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Выход"
                                                 message:@"Вы уверены?"
                                                delegate:self
                                       cancelButtonTitle:@"Отмена"
                                       otherButtonTitles:@"Да", nil];
    
    
    [av show];
    
    
    
}
- (void)doCheck
{
    
    
    
    web_service_type_request = @"check_user";
    
    NSURL *aUrl = [NSURL URLWithString:[[MySingleton sharedManager] url_webservice]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSUUID *oNSUUID = [[UIDevice currentDevice] identifierForVendor];
    
    NSString *postString = [NSString stringWithFormat:@"cmd=check_UID&uid=%@&session_id=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"],[oNSUUID UUIDString]];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    if(connection) {
        
    }
    responseData = [[NSMutableData alloc] init];
    
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex==1) {
        [self performSegueWithIdentifier:@"gologin" sender:nil];
    }
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MySingleton sharedManager] setSelected_product_name:@"all"];
    
    if([[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"] != 0)
    {
        
        
        if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"last_db_check_update"] doubleValue] + (1 * 1 * 60 * 1000) <  [[NSDate date] timeIntervalSince1970]*1000) {
            /* Start Update */
            
            [self check_update];
        }
        else
        {
           [self doCheck];
        }
        
    }
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"prodName contains[cd] %@",searchText];
    searchProductsArray = [NSArray arrayWithArray:[self.productsArray filteredArrayUsingPredicate:pred]];
    
}


- (void)reloadProducts {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *res = [db executeQuery:@"SELECT count(*) FROM products"];
    if ([res next]) {
        if([res intForColumnIndex:0] > 0){
            
            
            
            //NSLog(@"have records in db: %d", [res intForColumnIndex:0]);
            
            FMResultSet *fResult= [db executeQuery:@"SELECT `id`, `Направление` FROM products GROUP BY `Направление` ORDER BY `Направление` ASC"];
            
            /* Now we have to take these results in to a loop and then repeteadly loop it in order to get all the data in a   our Array Object */
            NSMutableArray *productsArrayTemp = [[NSMutableArray alloc] init];
            while([fResult next])
            {
                
                ProductInfo *prodInfo = [[ProductInfo alloc] init];
                prodInfo.prodId = [fResult stringForColumn:@"id"];
                prodInfo.prodName = [fResult stringForColumn:@"Направление"];
                
                
                [productsArrayTemp addObject:prodInfo];
                //NSLog(@"%@", productsArray);
                //[productsArray addObject:[fResult stringForColumn:@"Группа готовых продуктов"]];
                
            }
            
            
            self.productsArray = productsArrayTemp;
            
            
            
            
            
        }
    }
    
    
    [db close];
    
}

- (void)doUpdate {
    // Indeterminate mode
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    
    
    [[NSUserDefaults standardUserDefaults] setValue:[JSON objectForKey:@"usergroup"] forKey:@"UserGroup"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //recreate db
    
    NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS pr_users_history ( id INTEGER, `date_time` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, `user_id` INTEGER, `rec_link` TEXT);DROP TABLE IF EXISTS products;DROP TABLE IF EXISTS imgs;DROP TABLE IF EXISTS products_info;DROP TABLE IF EXISTS ingredients;DROP TABLE IF EXISTS ingredients_em;CREATE TABLE ingredients_em ( %@ );CREATE TABLE products ( %@ );CREATE TABLE products_info ( %@ );CREATE TABLE ingredients ( %@ , `user_price` TEXT NOT NULL DEFAULT '0');CREATE TABLE imgs ( `id` INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, `rec_name` TEXT, `type` INTEGER, `name` TEXT);",[JSON objectForKey:@"update_columns_ingr_em"], [JSON objectForKey:@"update_columns"], [JSON objectForKey:@"update_columns_prod"], [JSON objectForKey:@"update_columns_ingr"]];
    
    
    
    [db executeStatements:sql];
    
    
    [db beginTransaction];
    for (NSDictionary *dict in [JSON objectForKey:@"update"]) {
        NSMutableArray* cols = [[NSMutableArray alloc] init];
        NSMutableArray* vals = [[NSMutableArray alloc] init];
        for (id key in dict) {
            [cols addObject:key];
            [vals addObject:[dict objectForKey:key]];
        }
        NSMutableArray* newCols = [[NSMutableArray alloc] init];
        NSMutableArray* newVals = [[NSMutableArray alloc] init];
        for (int i = 0; i<[cols count]; i++) {
            [newCols addObject:[NSString stringWithFormat:@"'%@'", [cols objectAtIndex:i]]];
            [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
        }
        sql = [NSString stringWithFormat:@"insert into products (%@) values (%@)", [newCols componentsJoinedByString:@", "], [newVals componentsJoinedByString:@", "]];
        [db executeUpdate:sql];
    }
    [db commit];
    
    [db beginTransaction];
    for (NSDictionary *dict in [JSON objectForKey:@"update_prod"]) {
        NSMutableArray* cols = [[NSMutableArray alloc] init];
        NSMutableArray* vals = [[NSMutableArray alloc] init];
        for (id key in dict) {
            [cols addObject:key];
            [vals addObject:[dict objectForKey:key]];
        }
        NSMutableArray* newCols = [[NSMutableArray alloc] init];
        NSMutableArray* newVals = [[NSMutableArray alloc] init];
        for (int i = 0; i<[cols count]; i++) {
            [newCols addObject:[NSString stringWithFormat:@"'%@'", [cols objectAtIndex:i]]];
            [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
        }
        sql = [NSString stringWithFormat:@"insert into products_info (%@) values (%@)", [newCols componentsJoinedByString:@", "], [newVals componentsJoinedByString:@", "]];
        [db executeUpdate:sql];
    }
    [db commit];
    
    [db beginTransaction];
    for (NSDictionary *dict in [JSON objectForKey:@"update_ingr"]) {
        NSMutableArray* cols = [[NSMutableArray alloc] init];
        NSMutableArray* vals = [[NSMutableArray alloc] init];
        for (id key in dict) {
            [cols addObject:key];
            [vals addObject:[dict objectForKey:key]];
        }
        NSMutableArray* newCols = [[NSMutableArray alloc] init];
        NSMutableArray* newVals = [[NSMutableArray alloc] init];
        for (int i = 0; i<[cols count]; i++) {
            [newCols addObject:[NSString stringWithFormat:@"'%@'", [cols objectAtIndex:i]]];
            [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
        }
        sql = [NSString stringWithFormat:@"insert into ingredients (%@) values (%@)", [newCols componentsJoinedByString:@", "], [newVals componentsJoinedByString:@", "]];
        [db executeUpdate:sql];
    }
    [db commit];
    
    [db beginTransaction];
    for (NSDictionary *dict in [JSON objectForKey:@"update_ingr_em"]) {
        NSMutableArray* cols = [[NSMutableArray alloc] init];
        NSMutableArray* vals = [[NSMutableArray alloc] init];
        for (id key in dict) {
            [cols addObject:key];
            [vals addObject:[dict objectForKey:key]];
        }
        NSMutableArray* newCols = [[NSMutableArray alloc] init];
        NSMutableArray* newVals = [[NSMutableArray alloc] init];
        for (int i = 0; i<[cols count]; i++) {
            [newCols addObject:[NSString stringWithFormat:@"'%@'", [cols objectAtIndex:i]]];
            [newVals addObject:[NSString stringWithFormat:@"'%@'", [vals objectAtIndex:i]]];
        }
        sql = [NSString stringWithFormat:@"insert into ingredients_em (%@) values (%@)", [newCols componentsJoinedByString:@", "], [newVals componentsJoinedByString:@", "]];
        [db executeUpdate:sql];
    }
    [db commit];
    
    
    [db close];
    
    
    
    
    // UIImageView is a UIKit class, we have to initialize it on the main thread
    __block UIImageView *imageView;
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIImage *image = [UIImage imageNamed:@"check_image"];
        imageView = [[UIImageView alloc] initWithImage:image];
    });
    hud.customView = imageView;
    hud.mode = MBProgressHUDModeCustomView;
    hud.labelText = @"Готово";
    
    [self reloadProducts];
    [self.tableView reloadData];
    
    sleep(2);
}

- (void)getUpdate
{
    NSURL *aUrl = [NSURL URLWithString:[[MySingleton sharedManager] url_webservice]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"cmd=sync_products_table&uid=%ld", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"]];
    
    
    
    web_service_type_request = @"sync_products_table";
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    if(connection) {
        
    }
    responseData = [[NSMutableData alloc] init];
    
    hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;//MBProgressHUDModeDeterminate
    hud.labelText = @"Загрузка БД...";
    hud.dimBackground = YES;
    
    
    
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
    if(connection) {
        
    }
    responseData = [[NSMutableData alloc] init];
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    expectedLength = MAX([response expectedContentLength], 1);
    currentLength = 0;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    
    if([web_service_type_request  isEqual: @"sync_products_table"]) {
        currentLength += [data length];
        hud.progress = currentLength / (float)expectedLength;
    }
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    NSError *e = nil;
    NSData *jsonData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
    JSON = [NSJSONSerialization JSONObjectWithData:jsonData options: NSJSONReadingMutableContainers error: &e];
    
    
    if([web_service_type_request  isEqual: @"check_user"]) {
        
        if ([[JSON objectForKey:@"cmd"]  isEqual: @"exit"])
        {
           
           [self performSegueWithIdentifier:@"gologin" sender:nil];
        }
    }
    
    if([web_service_type_request  isEqual: @"sync_products_table"]) {
        
        
        
        
        
        hud.labelText = @"Обновление БД...";
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.minSize = CGSizeMake(135.f, 135.f);
        
        [hud showWhileExecuting:@selector(doUpdate) onTarget:self withObject:nil animated:YES];
        
        
    }
    
    if([web_service_type_request  isEqual: @"sync_check_update"]) {
        
        [[NSUserDefaults standardUserDefaults] setDouble:[[NSDate date] timeIntervalSince1970]*1000 forKey:@"last_db_check_update"];
        
        if ([[[JSON objectForKey:@"success"] stringValue]  isEqual: @"1"] && ![[JSON objectForKey:@"need_update"] isEqual:[[NSUserDefaults standardUserDefaults] stringForKey:@"last_db_update_time"]])//
        {
            [[NSUserDefaults standardUserDefaults] setValue:[JSON objectForKey:@"need_update"] forKey:@"last_db_update_time"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            //NSLog(@"need update");
            [self getUpdate];
        }
        
        //NSLog(@"Response from webservice: %@", JSON);
    }
    
}


- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if([web_service_type_request  isEqual: @"sync_products_table"]) {
        [hud hide:YES];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if([searchProductsArray count]==0) {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        else {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
        }
        return [searchProductsArray count];
        
    } else {
        
        return self.productsArray.count;
    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the selected cell in the usual way
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    ProductInfo *prod = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        prod = searchProductsArray[indexPath.row];
    } else {
        prod = self.productsArray[indexPath.row];
    }
    
    [[MySingleton sharedManager] setSelected_producttype_name:prod.prodName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self performSegueWithIdentifier:@"goProducts" sender:cell];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ProductInfo *prod = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        prod = searchProductsArray[indexPath.row];
    } else {
        prod = self.productsArray[indexPath.row];
    }
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = prod.prodName;
    
    return cell;
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
