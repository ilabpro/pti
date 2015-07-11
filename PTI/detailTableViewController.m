//
//  detailTableViewController.m
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "detailTableViewController.h"
#import "MySingleton.h"
#import "FMDB.h"
#import "threecolTableViewCell.h"
#import "RecSirIngrInfo.h"


@interface detailTableViewController ()
@property (weak, nonatomic) IBOutlet UILabel *recName;

@end
NSString *obolochka_rec;
NSString *poteri_rec;

double count_kg;
double count_prop;

double count_kg_sir;
double count_prop_sir;

double count_kg_ingr;
double count_prop_ingr;

double count_sum_price;


@implementation detailTableViewController
@synthesize writableDBPath;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIBarButtonItem *historyBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Image_eye"] style:UIBarButtonItemStylePlain target:self action:@selector(gohistory)];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_image"] style:UIBarButtonItemStylePlain target:self action:@selector(gohome)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:homeBarButtonItem, historyBarButtonItem, nil];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
- (void)gohome {
    [self performSegueWithIdentifier:@"goHome" sender:nil];
    
}
- (void)gohistory {
    [self performSegueWithIdentifier:@"goHistory" sender:nil];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self doLog:[NSString stringWithFormat:@"Просмотр деталей рецептуры %@ через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    self.recName.text = [[MySingleton sharedManager] current_recept_name];//[fResult stringForColumnIndex:0];
        
   
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `type`, `raw_material`, `kg` FROM products_info WHERE product_list_name='%@' and `type`='3'", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    obolochka_rec = [fResult stringForColumnIndex:1];
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `type`, `raw_material`, `kg` FROM products_info WHERE product_list_name='%@' and `type`='4'", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    poteri_rec = [fResult stringForColumnIndex:2];
    
    
    
    
    
    
    
    count_kg = 0.0;
    count_prop = 0.0;
    count_kg_sir = 0.0;
    count_prop_sir = 0.0;
    count_kg_ingr = 0.0;
    count_prop_ingr = 0.0;
    count_sum_price = 0.0;
    
    
    NSMutableArray *recSirArrayTemp = [[NSMutableArray alloc] init];
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `raw_material`, `kg`, `raw_prop`, (SELECT `price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as price FROM products_info WHERE product_list_name='%@' and `type`='1'", [[MySingleton sharedManager] selected_recept_name]]];
    while([fResult next])
    {
        
        RecSirIngrInfo *recSirInfo = [[RecSirIngrInfo alloc] init];
        
        recSirInfo.material = [fResult stringForColumnIndex:0];
        recSirInfo.kg = [fResult stringForColumnIndex:1];
        count_kg += [fResult doubleForColumnIndex:1];
        count_kg_sir += [fResult doubleForColumnIndex:1];
        recSirInfo.prop = [fResult stringForColumnIndex:2];
        count_prop += [fResult doubleForColumnIndex:2];
        count_prop_sir += [fResult doubleForColumnIndex:2];
        recSirInfo.price = [fResult stringForColumnIndex:3];
        
        count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:3];
        
        [recSirArrayTemp addObject:recSirInfo];
        //NSLog(@"%@", productsArray);
        
    }
    
    
    self.detailListSir = recSirArrayTemp;
    
   
    
    
    
    

    
    
    NSMutableArray *recIngrArrayTemp = [[NSMutableArray alloc] init];
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `raw_material`, `kg`, `raw_prop`, (SELECT `price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as price  FROM products_info WHERE product_list_name='%@' and `type`='2'", [[MySingleton sharedManager] selected_recept_name]]];
    while([fResult next])
    {
        
        RecSirIngrInfo *recIngrInfo = [[RecSirIngrInfo alloc] init];
        
        recIngrInfo.material = [fResult stringForColumnIndex:0];
        recIngrInfo.kg = [fResult stringForColumnIndex:1];
        count_kg += [fResult doubleForColumnIndex:1];
        count_kg_ingr += [fResult doubleForColumnIndex:1];
        recIngrInfo.prop = [fResult stringForColumnIndex:2];
        count_prop += [fResult doubleForColumnIndex:2];
        count_prop_ingr += [fResult doubleForColumnIndex:2];
        recIngrInfo.price = [fResult stringForColumnIndex:3];
        
        count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:3];
        
        [recIngrArrayTemp addObject:recIngrInfo];
        //NSLog(@"%@", productsArray);
        
    }
    
    
    self.detailListIngr = recIngrArrayTemp;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    if(section==0) {
        return 2;
    }
    else if(section==1) {
        
        return [self.detailListSir count]+1;
    }
    else if(section==2) {
        
        return [self.detailListIngr count]+1;
    }
    else if(section==3) {
        return 2;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;
    threecolTableViewCell *cell1 = nil;
    if(indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
        if(indexPath.row==0){
            cell.textLabel.text = @"Примерная стоимость 1 кг.";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f руб.", (count_sum_price/count_kg)];
        }
        else if(indexPath.row==1) {
            cell.textLabel.text = @"Оболочка";
            cell.detailTextLabel.text = obolochka_rec;
        }
    }
    else if(indexPath.section==1) {
        
        if(indexPath.row==0){
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
            cell1.header1.text = @"Сырье";
            cell1.header2.text = [NSString stringWithFormat:@"%.02f кг", count_kg_sir];//[NSString stringWithFormat:@"%@ кг", [@(count_kg_sir) stringValue]];
            cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop_sir];//[NSString stringWithFormat:@"%@%%", [@(count_prop_sir) stringValue]];
            return cell1;
        }
        else if(indexPath.row>0) {
            RecSirIngrInfo *recInf = self.detailListSir[indexPath.row-1];
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellRows" forIndexPath:indexPath];
            cell1.header1.text = recInf.material;
            cell1.header2.text = [NSString stringWithFormat:@"%g", [recInf.kg doubleValue]];//[@([recInf.kg doubleValue]) stringValue];
            cell1.header3.text = [NSString stringWithFormat:@"%g", [recInf.prop doubleValue]];//[@([recInf.prop doubleValue]) stringValue];
            return cell1;
        }
    }
    else if(indexPath.section==2) {
        
        if(indexPath.row==0){
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
            cell1.header1.text = @"Ингредиенты";
            cell1.header2.text = [NSString stringWithFormat:@"%.02f кг", count_kg_ingr];//[NSString stringWithFormat:@"%@ кг", [@(count_kg_ingr) stringValue]];
            cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop_ingr];//[NSString stringWithFormat:@"%@%%", [@(count_prop_ingr) stringValue]];
            return cell1;
        }
        else if(indexPath.row>0) {
            RecSirIngrInfo *recInf = self.detailListIngr[indexPath.row-1];
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellRows" forIndexPath:indexPath];
            cell1.header1.text = recInf.material;
            cell1.header2.text = [NSString stringWithFormat:@"%g", [recInf.kg doubleValue]];//[@([recInf.kg doubleValue]) stringValue];
            cell1.header3.text = [NSString stringWithFormat:@"%g", [recInf.prop doubleValue]];//[@([recInf.prop doubleValue]) stringValue];
            return cell1;
        }
    }
    else if(indexPath.section==3) {
        
        if(indexPath.row==0){
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
            cell1.header1.text = @"Общее кол-во";
            cell1.header2.text = [NSString stringWithFormat:@"%.02f кг", count_kg];
            cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop];
            return cell1;
        }
        else if(indexPath.row>0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
            cell.textLabel.text = @"Потери";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[poteri_rec intValue]];
            return cell;
        }
    }

    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
    }
    
   
    
    return cell;
  
}
- (NSString*)doHtml {
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    
    NSString* markupText =[NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><style>table, th, td{border: 1px solid #6e6e6e;}</style></head><body><h1>%@</h1>"
                           "<h3>Оболочка: %@</h3><table width=\"100%%\" border=\"0\"><tbody><tr><th style=\"text-align:left;width:70%%\">Сырье</th><th style=\"text-align:right;width:15%%\">"
                           "%.02f кг</th><th style=\"text-align:right\">%.02f%%</th></tr>",[[MySingleton sharedManager] current_recept_name] ,obolochka_rec, count_kg_sir, count_prop_sir];//[fResult stringForColumnIndex:0]
    [db close];
    
    for (RecSirIngrInfo *recInf in self.detailListSir) {
        
        markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><td style=\"text-align:left\">%@</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td></tr>",recInf.material ,[recInf.kg doubleValue], [recInf.prop doubleValue]]];
    }
    
    markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"</tbody></table><br/><br/><table width=\"100%%\" border=\"0\"><tbody><tr><th style=\"text-align:left;width:70%%\">Ингредиенты</th><th style=\"text-align:right;width:15%%\">%.02f кг</th><th style=\"text-align:right\">%.02f%%</th></tr>",count_kg_ingr ,count_prop_ingr]];
    
    for (RecSirIngrInfo *recInf in self.detailListIngr) {
        
        markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><td style=\"text-align:left\">%@</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td></tr>",recInf.material ,[recInf.kg doubleValue], [recInf.prop doubleValue]]];
    }
    
    markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"</tbody></table><h3>Потери: %@</h3></body></html>",[NSString stringWithFormat:@"%d",[poteri_rec intValue]]]];
    
    return markupText;
    
}
- (IBAction)sendemail:(id)sender {
    
    [self doLog:[NSString stringWithFormat:@"Отправка деталей рецептуры %@ на email через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    FMDatabase* db = [FMDatabase databaseWithPath:writableDBPath];
    [db open];
    
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    
    NSString *emailTitle = [NSString stringWithFormat:@"Детали рецептуры %@",[[MySingleton sharedManager] current_recept_name]];//!!!!!
    [db close];
    
    NSString *messageBody = @"Детали рецептуры в приложении";
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    [mc.navigationBar setTintColor:[UIColor whiteColor]];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:@[]];
    
    NSString *html = [self doHtml];
    
    
    
    NSString* filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* fileName = [NSString stringWithFormat:@"Детали рецептуры %@.html",[[MySingleton sharedManager] current_recept_name]];
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
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    NSLog (@"mail finished");
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)print:(id)sender {
    
    [self doLog:[NSString stringWithFormat:@"Печать деталей рецептуры %@ через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
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
