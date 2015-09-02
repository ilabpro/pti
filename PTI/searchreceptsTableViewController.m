//
//  searchreceptsTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "searchreceptsTableViewController.h"
#import "ReceptsInfo.h"
#import "MySingleton.h"
#import "FMDB.h"
#import "ParametrsInfo.h"

@interface searchreceptsTableViewController ()

@end
NSArray *searchReceptsArray;

@implementation searchreceptsTableViewController

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
    
    
    
    
    NSString *where_str = @"";
    
    if([[[MySingleton sharedManager] selected_product_name] isEqual: @"all"])
    {
        where_str = [NSString stringWithFormat:@"WHERE `Группа готовых продуктов` IS NOT NULL and `Направление`='%@'", [[MySingleton sharedManager] selected_producttype_name]];
    }
    else
    {
        where_str = [NSString stringWithFormat:@"WHERE `Группа готовых продуктов`='%@' and `Направление`='%@'", [[MySingleton sharedManager] selected_product_name], [[MySingleton sharedManager] selected_producttype_name]];
    }
    
    
    for (ParametrsInfo *par in [[MySingleton sharedManager] parametrSetList]) {
        
        where_str = [where_str stringByAppendingString:[NSString stringWithFormat:@" and `%@`='%@'", par.parName, par.parSel]];
    }
    
    
    //NSLog(@"%@",where_str);
    
   
    
    if([[[MySingleton sharedManager] selected_ingr_name] isEqual: @""])
    {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `Название`, `ФИО автора`, `ФИО ШТ`, `Ссылка`, `new` FROM products %@ ORDER BY `Название` ASC", where_str]];
    }
    else
    {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `Название`, `ФИО автора`, `ФИО ШТ`, `Ссылка`, `new`, (select products_info.`id` from products_info where products_info.`product_list_name`=products.`Ссылка` and products_info.`raw_material`='%@' LIMIT 1) as have_ingr FROM products %@ GROUP BY products.`Ссылка` HAVING have_ingr > 0 ORDER BY `Название` ASC", [[MySingleton sharedManager] selected_ingr_name], where_str]];
    }
    
    
   
    
    
    /* Now we have to take these results in to a loop and then repeteadly loop it in order to get all the data in a   our Array Object */
    NSMutableArray *receptsArrayTemp = [[NSMutableArray alloc] init];
    while([fResult next])
    {
        
        ReceptsInfo *recInfo = [[ReceptsInfo alloc] init];
        
        recInfo.recId = [fResult stringForColumnIndex:0];
        recInfo.recName = [fResult stringForColumnIndex:1];
        recInfo.recFio = [fResult stringForColumnIndex:2];
        recInfo.recFioSht = [fResult stringForColumnIndex:3];
        recInfo.recLink = [fResult stringForColumnIndex:4];
        recInfo.recNew = [fResult stringForColumnIndex:5];
        
        
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
    searchReceptsArray = [NSArray arrayWithArray:[self.receptsArray filteredArrayUsingPredicate:pred]];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
       
        if([searchReceptsArray count]==0) {
       
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        else {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
        }
        return [searchReceptsArray count];
        
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
        rec = searchReceptsArray[indexPath.row];
    } else {
        rec = self.receptsArray[indexPath.row];
    }
    
    [[MySingleton sharedManager] setSelected_recept_name:rec.recLink];
    [[MySingleton sharedManager] setCurrent_recept_name:rec.recName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self doHistory:[NSString stringWithFormat:@"%@", rec.recLink]];
    
    [self performSegueWithIdentifier:@"goDetail" sender:cell];
    
}
- (void)doHistory:(NSString*)logtext
{
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
   
    NSString *sql = [NSString stringWithFormat:@"insert into pr_users_history (`user_id`, `rec_link`) values ('%ld', '%@')", (long)[[NSUserDefaults standardUserDefaults] integerForKey:@"UserId"], logtext];
    [db executeStatements:sql];
    [db close];
    
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
       
        rec = searchReceptsArray[indexPath.row];
    } else {
       
        rec = self.receptsArray[indexPath.row];
    }
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = rec.recName;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"ФИО автора: %@\nФИО ШТ: %@", rec.recFio, rec.recFioSht];
    cell.detailTextLabel.numberOfLines = 0;
    //cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.textColor = [self colorWithHexString:@"BCBCC3"];
    
    
    
    return cell;

}
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
   
    ReceptsInfo *rec = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        rec = searchReceptsArray[indexPath.row];
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
- (CGFloat) tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
        return  (44.0 + (2 - 1) * 19.0);
    
    
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
