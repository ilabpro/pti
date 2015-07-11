//
//  ingredientTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "ingredientTableViewController.h"
#import "FMDB.h"
#import "IngredientInfo.h"
#import "MySingleton.h"

@interface ingredientTableViewController ()

@end


NSArray *searchIngredientsArray;
@implementation ingredientTableViewController

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
    [[[MySingleton sharedManager] parametrSetList] removeAllObjects];
    [[MySingleton sharedManager] setSelected_ingr_name:@""];
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    [self reloadIngredients];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the selected cell in the usual way
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    IngredientInfo *ingr = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ingr = searchIngredientsArray[indexPath.row];
    } else {
        ingr = self.ingredientsArray[indexPath.row];
    }
    
    [[MySingleton sharedManager] setSelected_ingr_name:ingr.ingrName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self performSegueWithIdentifier:@"goRecepts" sender:cell];
    
}
- (void)reloadIngredients {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    //NSLog(@"%@",[[MySingleton sharedManager] selected_product_name]);
    
    if([[[MySingleton sharedManager] selected_product_name] isEqual: @"all"])
    {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT products.`Ссылка`,products.`Направление`,products.`Группа готовых продуктов`,products_info.`raw_material` "
                  "FROM products "
                  "INNER JOIN products_info "
                  "ON products.`Ссылка`=products_info.`product_list_name` "
                  "WHERE products.`Направление`='%@' and products.`Группа готовых продуктов` IS NOT NULL and (products_info.`type`='1' or products_info.`type`='2') GROUP BY products_info.`raw_material` ORDER BY products_info.`raw_material`;",[[MySingleton sharedManager] selected_producttype_name]]];
    }
    else
    {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT products.`Ссылка`,products.`Направление`,products.`Группа готовых продуктов`,products_info.`raw_material` "
                                   "FROM products "
                                   "INNER JOIN products_info "
                                   "ON products.`Ссылка`=products_info.`product_list_name` "
                                   "WHERE products.`Направление`='%@' and products.`Группа готовых продуктов`='%@' and (products_info.`type`='1' or products_info.`type`='2') GROUP BY products_info.`raw_material` ORDER BY products_info.`raw_material`;",[[MySingleton sharedManager] selected_producttype_name], [[MySingleton sharedManager] selected_product_name]]];
    }
    
    
    
    
    /* Now we have to take these results in to a loop and then repeteadly loop it in order to get all the data in a   our Array Object */
    NSMutableArray *ingredientsArrayTemp = [[NSMutableArray alloc] init];
    while([fResult next])
    {
        
        IngredientInfo *ingrInfo = [[IngredientInfo alloc] init];
        ingrInfo.ingrId = @"0";
        ingrInfo.ingrName = [fResult stringForColumn:@"raw_material"];
        
        
        [ingredientsArrayTemp addObject:ingrInfo];
        //NSLog(@"%@", productsArray);
        //[productsArray addObject:[fResult stringForColumn:@"Группа готовых продуктов"]];
        
    }
    
    
    self.ingredientsArray = ingredientsArrayTemp;

    
    
    
    
    
    
    
    
    [db close];
    [self.tableView reloadData];
    
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
    
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ingrName contains[cd] %@",searchText];
    searchIngredientsArray = [NSArray arrayWithArray:[self.ingredientsArray filteredArrayUsingPredicate:pred]];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if([searchIngredientsArray count]==0) {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        else {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
            
        }
        return [searchIngredientsArray count];
        
    } else {
        
        return self.ingredientsArray.count;
    }

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    IngredientInfo *ingr = nil;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        ingr = searchIngredientsArray[indexPath.row];
    } else {
        ingr = self.ingredientsArray[indexPath.row];
    }
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = ingr.ingrName;
    
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
