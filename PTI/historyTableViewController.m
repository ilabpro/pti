//
//  historyTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 11.07.15.
//  Copyright © 2015 ilab.pro LLC. All rights reserved.
//

#import "historyTableViewController.h"
#import "ReceptsInfo.h"
#import "MySingleton.h"
#import "FMDB.h"
#import "ParametrsInfo.h"
@interface historyTableViewController ()

@end
NSArray *searchReceptsArray2;
@implementation historyTableViewController
@synthesize writableDBPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    [self reloadRecepts];
}
- (void)reloadRecepts {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    //NSLog(@"%@",[[MySingleton sharedManager] selected_product_name]);
    
    
    
    
    
    fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT *, (SELECT `Название` from products WHERE products.`Ссылка` = pr_users_history.`rec_link` limit 1) as `Название`, (SELECT `ФИО автора` from products WHERE products.`Ссылка` = pr_users_history.`rec_link` limit 1) as `ФИО автора`, (SELECT `ФИО ШТ` from products WHERE products.`Ссылка` = pr_users_history.`rec_link` limit 1) as `ФИО ШТ`, (SELECT `new` from products WHERE products.`Ссылка` = pr_users_history.`rec_link` limit 1) as `new` FROM pr_users_history WHERE `user_id`='%ld' and `Название` IS NOT NULL ORDER BY `date_time` DESC LIMIT 200", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"]]];
    
    
    
    
    
    
    /* Now we have to take these results in to a loop and then repeteadly loop it in order to get all the data in a   our Array Object */
    NSMutableArray *receptsArrayTemp = [[NSMutableArray alloc] init];
    while([fResult next])
    {
        
        ReceptsInfo *recInfo = [[ReceptsInfo alloc] init];
        
                
        recInfo.recId = [fResult stringForColumnIndex:0];
        recInfo.recName = [fResult stringForColumnIndex:4];
        recInfo.recView = [fResult stringForColumnIndex:1];
        recInfo.recFio = [fResult stringForColumnIndex:5];
        recInfo.recFioSht = [fResult stringForColumnIndex:6];
        recInfo.recLink = [fResult stringForColumnIndex:3];
        recInfo.recNew = [fResult stringForColumnIndex:7];
        
        
        [receptsArrayTemp addObject:recInfo];
        //NSLog(@"%@", productsArray);
        //[productsArray addObject:[fResult stringForColumn:@"Группа готовых продуктов"]];
        
    }
    
    if([receptsArrayTemp count] == 0) {
        
        // Display a message when the table is empty
        UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        messageLabel.text = @"Рецептур не найдено";
        messageLabel.textColor = [self colorWithHexString:@"BCBCC3"];
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = NSTextAlignmentCenter;
        [messageLabel sizeToFit];
        
        self.tableView.backgroundView = messageLabel;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    
    self.receptsArray = receptsArrayTemp;
    
    
    
    
    
    
    
    
    
    [db close];
    [self.tableView reloadData];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"recName contains[cd] %@",searchText];
    searchReceptsArray2 = [NSArray arrayWithArray:[self.receptsArray filteredArrayUsingPredicate:pred]];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        if([searchReceptsArray2 count]==0) {
            
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        else {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
        }
        return [searchReceptsArray2 count];
        
    } else {
        
        return self.receptsArray.count;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the selected cell in the usual way
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    ReceptsInfo *rec = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rec = searchReceptsArray2[indexPath.row];
    } else {
        rec = self.receptsArray[indexPath.row];
    }
    
    [[MySingleton sharedManager] setSelected_recept_name:rec.recLink];
    [[MySingleton sharedManager] setCurrent_recept_name:rec.recName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self performSegueWithIdentifier:@"goDetail" sender:cell];
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    static NSString *CellIdentifier = @"Cell";
    // NSLog(@"%@", searchReceptsArray);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ReceptsInfo *rec = nil;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        
        rec = searchReceptsArray2[indexPath.row];
    } else {
        
        rec = self.receptsArray[indexPath.row];
    }
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = rec.recName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Просмотрено: %@\nФИО автора: %@\nФИО ШТ: %@", [self getDateFromString:rec.recView], rec.recFio, rec.recFioSht];
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.textColor = [self colorWithHexString:@"BCBCC3"];
    return cell;
    
}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ReceptsInfo *rec = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rec = searchReceptsArray2[indexPath.row];
    } else {
        rec = self.receptsArray[indexPath.row];
    }
    //NSLog(@"Test: %@ ---- %@", rec.recName, rec.recNew);
    if([rec.recNew  isEqual: @"1"])
    {
        cell.backgroundColor = [self colorWithHexString:@"EBEBF1"];
    }
    else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
}
-(NSString *)getDateFromString:(NSString *)string
{
    
    NSString * dateString = [NSString stringWithFormat: @"%@",string];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd' 'HH':'mm':'ss'" ];
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd.MM.yyyy"];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    
    return stringFromDate;
}
- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return  (44.0 + (3 - 1) * 19.0);
    
    
}
-(UIColor*)colorWithHexString:(NSString*)hex
{
    NSString *cString = [[hex stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) return [UIColor grayColor];
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    
    if ([cString length] != 6) return  [UIColor grayColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

@end
