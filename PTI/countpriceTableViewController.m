//
//  countpriceTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 01.06.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "countpriceTableViewController.h"
#import "MySingleton.h"
#import "FMDB.h"
#import "twoTableViewCell.h"
#import "RecSirIngrInfo.h"

@interface countpriceTableViewController ()

@end

@implementation countpriceTableViewController
@synthesize writableDBPath;

double count_sum;
double count_sum_kg;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //tapper = [[UITapGestureRecognizer alloc]
    //          initWithTarget:self action:@selector(handleSingleTap:)];
    //tapper.cancelsTouchesInView = NO;
    //[self.view addGestureRecognizer:tapper];
   
    count_sum = 0.0;
    
    
    
}
- (NSString*)doHtml {
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    
    
    NSString* markupText =[NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><style>table, th, td{border: 1px solid #6e6e6e;}</style></head><body><h1>%@</h1><h2>Расчет стоимости за 1 кг.</h2>"
                           "<table width=\"100%%\" border=\"0\"><tbody><tr><th style=\"text-align:left;width:70%%\">Ингредиент</th><th style=\"text-align:right\">Цена за кг.</th></tr>",[[MySingleton sharedManager] current_recept_name]];//[fResult stringForColumnIndex:0]
    
    
    for (RecSirIngrInfo *recInf in self.detailListIngr) {
        
        markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><td style=\"text-align:left\">%@</td><td style=\"text-align:right\">%@</td></tr>",recInf.material ,[@([recInf.price doubleValue]) stringValue]]];
    }
    
    markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><th style=\"text-align:right;width:70%%\">Итого стоимость 1 кг.</th><th style=\"text-align:right\">%@</th></tr></tbody></table></body></html>",[NSString stringWithFormat:@"%.02f руб.", count_sum/count_sum_kg]]];
    
    
    
    [db close];
    return markupText;
}
- (IBAction)sendemail:(id)sender {
    
    [self doLog:[NSString stringWithFormat:@"Отправка стоимости рецептуры %@ на email через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    
    NSString *emailTitle = [NSString stringWithFormat:@"Расчет рецептуры %@",[[MySingleton sharedManager] current_recept_name]];//!!!!!
    [db close];
    
    NSString *messageBody = @"Расчет рецептуры в приложении";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc.navigationBar setTintColor:[UIColor whiteColor]];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:@[]];
    
    NSString *html = [self doHtml];
    
    
    
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"Расчет рецептуры %@.html",[[MySingleton sharedManager] current_recept_name]];
    NSString* fileAtPath = [filePath stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileAtPath]) {
        [[NSFileManager defaultManager] createFileAtPath:fileAtPath contents:nil attributes:nil];
    }
    
    BOOL res = [[html dataUsingEncoding:NSUTF8StringEncoding] writeToFile:fileAtPath atomically:NO];
    
    if (!res) {
        [[[UIAlertView alloc] initWithTitle:@"Ошибка создания файла" message:@"Проверьте параметры доступа!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }else{
        NSLog(@"Data saved! File path = %@", fileName);
        [
         
         
         mc addAttachmentData:[NSData dataWithContentsOfFile:fileAtPath]
         mimeType:@"text/html"
         fileName:fileName];
        [self presentViewController:mc animated:YES completion:nil];
        
        
        
    }
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog (@"mail finished");
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)print:(id)sender {
    
    [self doLog:[NSString stringWithFormat:@"Печать стоимости рецептуры %@ через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    if (![UIPrintInteractionController isPrintingAvailable])
        return;
    
    
    
   
    
    
    NSString* markupText = [self doHtml];
    
    UIMarkupTextPrintFormatter* printFormatter =[[UIMarkupTextPrintFormatter alloc] initWithMarkupText:markupText];
    
    UIPrintInteractionController* printInteractionController =[UIPrintInteractionController sharedPrintController];
    printInteractionController.printFormatter =printFormatter;
    printInteractionController.delegate =self;
    //printInteractionController.showsPageRange =YES;
    
    
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        UIBarButtonItem *item = self.print_but ;
        
        UIView *view = [item valueForKey:@"view"];
        
        if(view){
            
            CGRect frame=view.frame;
            [printInteractionController presentFromRect:frame inView:view.superview animated:YES completionHandler:nil];
        }
    }
    else {
        [printInteractionController presentAnimated:YES completionHandler:nil];
    }
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self doLog:[NSString stringWithFormat:@"Просмотр стоимости рецептуры %@ через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    
    count_sum_kg = 0.0;
    NSMutableArray *recSirArrayTemp = [[NSMutableArray alloc] init];
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `raw_material`, `kg`, `raw_prop`, (SELECT `price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as price  FROM products_info WHERE product_list_name='%@' and (`type`='1' or `type`='2') ORDER BY `type` ASC", [[MySingleton sharedManager] selected_recept_name]]];
    while([fResult next])
    {
        
        RecSirIngrInfo *recSirInfo = [[RecSirIngrInfo alloc] init];
        
        recSirInfo.material = [fResult stringForColumnIndex:0];
        recSirInfo.kg = [fResult stringForColumnIndex:1];
        count_sum_kg += [fResult doubleForColumnIndex:1];
        recSirInfo.prop = [fResult stringForColumnIndex:2];
        recSirInfo.price = [fResult stringForColumnIndex:3];
        
        count_sum += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:3];
        
        [recSirArrayTemp addObject:recSirInfo];
        //NSLog(@"%f-%f", [fResult doubleForColumnIndex:1], [fResult doubleForColumnIndex:3]);
        
    }
    
    
    self.detailListIngr = recSirArrayTemp;
    
    //NSLog(@"%f", count_sum/count_sum_kg);
    
}
- (void)doLog:(NSString*)logtext
{
    NSURL *aUrl = [NSURL URLWithString:[[MySingleton sharedManager] url_webservice]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:aUrl
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    
    [request setHTTPMethod:@"POST"];
    NSString *postString = [NSString stringWithFormat:@"cmd=print_log&uid=%@&text=%@",[[NSUserDefaults standardUserDefaults] stringForKey:@"UserId"], logtext];
    
    [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *connection= [[NSURLConnection alloc] initWithRequest:request
                                                                 delegate:self];
    if(connection) {
        
    }
    
    
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
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
    return self.detailListIngr.count+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    twoTableViewCell *cell1 = nil;
    
    if(indexPath.row==0){
        cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
        cell1.header1.text = @"Ингредиент";
        cell1.header3.text = @"Цена за кг.";//[NSString stringWithFormat:@"%@ кг", [@(count_kg_sir) stringValue]];
        //cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop_sir];//[NSString stringWithFormat:@"%@%%", [@(count_prop_sir) stringValue]];
        return cell1;
    }
    else if(indexPath.row>0 && indexPath.row < self.detailListIngr.count+1) {
        RecSirIngrInfo *recInf = self.detailListIngr[indexPath.row-1];
       
        cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellRows" forIndexPath:indexPath];
        cell1.header1.text = recInf.material;
        cell1.header2.text = [@([recInf.price doubleValue]) stringValue];
        cell1.header2.tag = indexPath.row-1;
        [cell1.header2 addTarget:self
                          action:@selector(countMoney:)
            forControlEvents:UIControlEventEditingChanged];

        cell1.header3.text = recInf.kg;
        return cell1;
    }
    else{
        NSLog(@"%@", @"ok");
        cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
        cell1.header1.text = @"Итого стоимость 1 кг.";
        cell1.header3.text = [NSString stringWithFormat:@"%.02f руб.", count_sum/count_sum_kg];
        return cell1;
    }
    
    return cell1;

}

- (void)countMoney:(UITextField *)theTextField {
    
    // Dispose of any resources that can be recreated.
    count_sum = 0.0;
   
    
    
    RecSirIngrInfo *recInf = self.detailListIngr[theTextField.tag];
    recInf.price = theTextField.text;
    
    
    for (RecSirIngrInfo *cell in self.detailListIngr) {
        count_sum += [cell.kg doubleValue]*[cell.price doubleValue];
    }
       
    
    //[self.tableView reloadData];
    
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.detailListIngr.count+1 inSection:0];
        NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    
    
   
    
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
