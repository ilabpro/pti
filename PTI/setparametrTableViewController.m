//
//  setparametrTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "setparametrTableViewController.h"
#import "FMDB.h"
#import "ParametrsInfo.h"
#import "MySingleton.h"

@interface setparametrTableViewController ()

@end

@implementation setparametrTableViewController
@synthesize parName;
@synthesize writableDBPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"close_image"] style:UIBarButtonItemStylePlain target:self action:@selector(emptyAction)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects: saveBarButtonItem, nil];
    
    self.title = parName;
    [self reloadParametrsVars];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)reloadParametrsVars {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
   
    NSMutableArray *varsArrayTemp = [[NSMutableArray alloc] init];
    
    if ([parName isEqual: @"Ценовой сегмент"]) {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT `%@`, (case `Ценовой сегмент` "
                                   "        when \"Премиум\" then \"0\" "
                                   "        when \"Средний премиум класс\" then \"1\" "
                                   "        when \"Средний класс\" then \"2\" "
                                   "        when \"Средний\" then \"3\" "
                                   "        when \"Средний эконом класс\" then \"4\" "
                                   "        when \"Эконом\" then \"5\" end) AS sort FROM products WHERE `Направление`='%@' and `Группа готовых продуктов`='%@' and `%@`!='' GROUP BY `%@` ORDER BY `sort` ASC", parName, [[MySingleton sharedManager] selected_producttype_name],[[MySingleton sharedManager] selected_product_name], parName, parName]];
    }
    else {
        fResult= [db executeQuery:[NSString stringWithFormat:@"SELECT `%@` FROM products WHERE `Направление`='%@' and `Группа готовых продуктов`='%@' and `%@`!='' GROUP BY `%@` ORDER BY `%@` ASC", parName, [[MySingleton sharedManager] selected_producttype_name], [[MySingleton sharedManager] selected_product_name], parName, parName, parName]];
    }
    
   
    
    while ([fResult next]) {
        
        ParametrsInfo *varInfo = [[ParametrsInfo alloc] init];
        varInfo.parSel = @"-";
        varInfo.parName = [fResult stringForColumnIndex:0];
        [varsArrayTemp addObject:varInfo];
        
    }
    
    
    self.varsArray = varsArrayTemp;
    
    
    
    
    
    
    
    
    
    [db close];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)emptyAction
{
    [self clearFilterPar];
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    return self.varsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    ParametrsInfo *var = self.varsArray[indexPath.row];
    
    [self clearFilterPar];
    
    ParametrsInfo *varInfo = [[ParametrsInfo alloc] init];
    varInfo.parSel = var.parName;
    varInfo.parName = parName;
    [[[MySingleton sharedManager] parametrSetList] addObject:varInfo];
    
    
    //[[MySingleton sharedManager] setSelected_ingr_name:ingr.ingrName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] parametrSetList]);
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.navigationController popViewControllerAnimated:YES];
    
}
-(void)clearFilterPar
{
    NSMutableIndexSet *discardedItems = [NSMutableIndexSet indexSet];
    NSUInteger index = 0;
    
    for (ParametrsInfo *par in [[MySingleton sharedManager] parametrSetList]) {
        if ([par.parName isEqual:parName]) {
           
            [discardedItems addIndex:index];
            
        }
        index++;
    }
    [[[MySingleton sharedManager] parametrSetList] removeObjectsAtIndexes:discardedItems];
    
    
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    ParametrsInfo *var = self.varsArray[indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
        for (ParametrsInfo *par in [[MySingleton sharedManager] parametrSetList]) {
           
            
            if ([par.parName isEqual:parName] && [par.parSel isEqual:var.parName]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
           
        }
        
    }
    
    
    
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = var.parName;
    //cell.detailTextLabel.text = var.parSel;
    
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
