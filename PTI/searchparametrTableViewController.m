//
//  searchparametrTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 30.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "searchparametrTableViewController.h"
#import "FMDB.h"
#import "ParametrsInfo.h"
#import "MySingleton.h"
#import "setparametrTableViewController.h"

@interface searchparametrTableViewController ()

@end

@implementation searchparametrTableViewController
@synthesize writableDBPath;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIBarButtonItem *editBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"найти" style:UIBarButtonItemStylePlain target:self action:@selector(searchAction)];
    
    UIBarButtonItem *saveBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_image"] style:UIBarButtonItemStylePlain target:self action:@selector(homeAction)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:editBarButtonItem, saveBarButtonItem, nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[MySingleton sharedManager] setSelected_ingr_name:@""];
    [self reloadParametrs];
    
}
-(void)searchAction
{
    [self performSegueWithIdentifier:@"goRecepts" sender:self];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Find the selected cell in the usual way
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    //ParametrsInfo *par = self.parametrsArray[indexPath.row];
    
    //[[MySingleton sharedManager] setSelected_ingr_name:ingr.ingrName];
    
    
    //NSLog(@"%@", [[MySingleton sharedManager] selected_product_name]);
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self performSegueWithIdentifier:@"goSetpar" sender:cell];
    
}

-(void)homeAction
{
    [self performSegueWithIdentifier:@"goHome" sender:self];
}
- (void)reloadParametrs {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    FMResultSet *fRes = nil;
    NSMutableArray *parametrsArrayTemp = [[NSMutableArray alloc] init];
    //NSLog(@"%@",[[MySingleton sharedManager] parametrSetList]);
    
    fResult= [db executeQuery:@"PRAGMA table_info('products')"];
    NSString *parName = @"";
    Boolean can_iterate = false;
    while ([fResult next]) {
        parName = [fResult stringForColumnIndex:1];
        if([parName isEqual: @"Название"]) can_iterate = false;
        if(can_iterate) {
            //
            fRes = [db executeQuery:[NSString stringWithFormat:@"SELECT count(*) FROM products WHERE `Направление`='%@' and `Группа готовых продуктов`='%@' and `%@`!=''", [[MySingleton sharedManager] selected_producttype_name], [[MySingleton sharedManager] selected_product_name], parName]];
            //NSLog(@"%@",[NSString stringWithFormat:@"SELECT count(*) FROM products WHERE `Направление`='%@' and `Группа готовых продуктов`='%@' and `%@`!=''", [[MySingleton sharedManager] selected_producttype_name], [[MySingleton sharedManager] selected_product_name], parName]);
            [fRes next];
            if([fRes intForColumnIndex:0] > 0) {
                ParametrsInfo *parInfo = [[ParametrsInfo alloc] init];
                parInfo.parSel = @"-";
                for (ParametrsInfo *par in [[MySingleton sharedManager] parametrSetList]) {
                    
                    
                    if ([par.parName isEqual:parName]) {
                        parInfo.parSel = par.parSel;
                    }
                    
                    
                }
                
                parInfo.parName = parName;
                
                
                [parametrsArrayTemp addObject:parInfo];
            }
            
            
            
        }
        if([parName isEqual: @"Группа готовых продуктов"]) can_iterate = true;
    }
    
    
    
    
    
    
    
    
    
    self.parametrsArray = parametrsArrayTemp;
    
    
    
    
    
    
    
    
    
    [db close];
    
    [self.tableView reloadData];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.parametrsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    ParametrsInfo *par = self.parametrsArray[indexPath.row];
    
    
    // Configure the cell.
    //We are configuring my cells in table view
    
    
    
    cell.textLabel.text = par.parName;
    
    cell.detailTextLabel.text = par.parSel;
    
    cell.detailTextLabel.textColor = [self colorWithHexString:@"902646"];
    return cell;

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goSetpar"]) {
        setparametrTableViewController *ViewController = [segue destinationViewController];
        ParametrsInfo *par = self.parametrsArray[[self.tableView indexPathForSelectedRow].row];
        ViewController.parName = par.parName;
    }
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}


@end
