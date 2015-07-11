//
//  mainTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "mainTableViewController.h"
#import "MySingleton.h"


#import "FMDB.h"
#import "ProductInfo.h"

@interface mainTableViewController ()

@end



NSArray *searchProductsArray1;



@implementation mainTableViewController
@synthesize writableDBPath;


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setAutomaticallyAdjustsScrollViewInsets:YES];
    [self setExtendedLayoutIncludesOpaqueBars:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    
   
    
    
    
    UIBarButtonItem *filterBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_image"] style:UIBarButtonItemStylePlain target:self action:@selector(goingr)];
    UIBarButtonItem *historyBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Image_eye"] style:UIBarButtonItemStylePlain target:self action:@selector(gohistory)];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_image"] style:UIBarButtonItemStylePlain target:self action:@selector(gohome)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:homeBarButtonItem, historyBarButtonItem, filterBarButtonItem, nil];
    
    
     [[MySingleton sharedManager] setSelected_product_name:@"all"];
    
    
        [self reloadProducts];
        
        
        
    
    

    
}

- (void)goingr {
           [self performSegueWithIdentifier:@"goAllingr" sender:nil];
    
}
- (void)gohome {
    [self performSegueWithIdentifier:@"goHome" sender:nil];
    
}
- (void)gohistory {
    [self performSegueWithIdentifier:@"goHistory" sender:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MySingleton sharedManager] setSelected_product_name:@"all"];
    
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
    searchProductsArray1 = [NSArray arrayWithArray:[self.productsArray filteredArrayUsingPredicate:pred]];
   
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
            
            FMResultSet *fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `Группа готовых продуктов` FROM products WHERE `Направление`='%@' GROUP BY `Группа готовых продуктов` ORDER BY `Группа готовых продуктов` ASC", [[MySingleton sharedManager] selected_producttype_name]]];
            
            /* Now we have to take these results in to a loop and then repeteadly loop it in order to get all the data in a   our Array Object */
            NSMutableArray *productsArrayTemp = [[NSMutableArray alloc] init];
            while([fResult next])
            {
                
                ProductInfo *prodInfo = [[ProductInfo alloc] init];
                prodInfo.prodId = [fResult stringForColumn:@"id"];
                prodInfo.prodName = [fResult stringForColumn:@"Группа готовых продуктов"];
                
                
                [productsArrayTemp addObject:prodInfo];
                //NSLog(@"%@", productsArray);
                //[productsArray addObject:[fResult stringForColumn:@"Группа готовых продуктов"]];
                
            }
            
            
            self.productsArray = productsArrayTemp;
            
            
           
            
            
        }
    }
    
    
    [db close];
    
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
        if([searchProductsArray1 count]==0) {
           [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        }
        else {
            [self.searchDisplayController.searchResultsTableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
           
        }
        return [searchProductsArray1 count];
        
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
        prod = searchProductsArray1[indexPath.row];
    } else {
        prod = self.productsArray[indexPath.row];
    }
    
    [[MySingleton sharedManager] setSelected_product_name:prod.prodName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.searchDisplayController setActive:NO animated:YES];
    
    [self performSegueWithIdentifier:@"goSearchtype" sender:cell];
    
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
        prod = searchProductsArray1[indexPath.row];
    } else {
        prod = self.productsArray[indexPath.row];
    }
    
       cell.textLabel.text = prod.prodName;
    
    return cell;
}


@end
