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


double count_sum_price,count_vklad;
UIGestureRecognizer *tapper;


NSMutableArray *photo;
NSMutableArray *photos_can_del;
UIActionSheet *attachmentMenuSheet;
int totalonlinewebCount;
int totalofflinewebCount;
FMDatabaseQueue* queue;

/*
UIPageControl *pageControl;
UIScrollView *scrollView;
*/

@implementation detailTableViewController
@synthesize writableDBPath;
@synthesize hud;
@synthesize sliderView;
@synthesize photos_scrollView;
@synthesize photos_pagecontrol;
@synthesize showwebbtn;
@synthesize delbut;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    photo = [[NSMutableArray alloc] init];
    photos_can_del = [[NSMutableArray alloc] init];
    UIBarButtonItem *historyBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Image_eye"] style:UIBarButtonItemStylePlain target:self action:@selector(gohistory)];
    UIBarButtonItem *homeBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"home_image"] style:UIBarButtonItemStylePlain target:self action:@selector(gohome)];
    
    self.navigationItem.rightBarButtonItems = [[NSArray alloc] initWithObjects:homeBarButtonItem, historyBarButtonItem, nil];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pti.db"];
    queue = [FMDatabaseQueue databaseQueueWithPath:writableDBPath];
    
     [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)    name:UIDeviceOrientationDidChangeNotification  object:nil];
    
    tapper = [[UITapGestureRecognizer alloc]
              initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapper];
    
   [photos_pagecontrol addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    
    
}
- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}
- (void)gohome {
    [self performSegueWithIdentifier:@"goHome" sender:nil];
    
}
- (void)gohistory {
    [self performSegueWithIdentifier:@"goHistory" sender:nil];
    
}
- (void)orientationChanged:(NSNotification *)notification{
    [self buildSlider];
    [self refreshcurrentPage];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    
   
    
    
    
    [self doLog:[NSString stringWithFormat:@"Просмотр деталей рецептуры %@ через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    
    
    
   [queue inDatabase:^(FMDatabase *db) {
    
    
    
    FMResultSet *fResult = nil;
    
    
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `imgs` FROM products WHERE `Ссылка`='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    [fResult next];
    totalonlinewebCount = [fResult intForColumnIndex:1];
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT count(*) FROM imgs WHERE `rec_name`='%@' and `type`='1'", [[MySingleton sharedManager] selected_recept_name]]];
    [fResult next];
    totalofflinewebCount = [fResult intForColumnIndex:0];
    
    
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
    count_vklad = 0.0;
    
    NSMutableArray *recSirArrayTemp = [[NSMutableArray alloc] init];
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `raw_material`, `kg`, `raw_prop`, (SELECT `price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as price, (SELECT `user_price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as user_price FROM products_info WHERE product_list_name='%@' and `type`='1'", [[MySingleton sharedManager] selected_recept_name]]];
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
        
        if(![[fResult stringForColumnIndex:4]  isEqual: @"0"])
        {
            
            recSirInfo.price = [fResult stringForColumnIndex:4];
            count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:4];
        }
        else
        {
           recSirInfo.price = [fResult stringForColumnIndex:3];
           count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:3];
        }
        
        
        
        
        
        [recSirArrayTemp addObject:recSirInfo];
        //NSLog(@"%@", productsArray);
        
    }
    
    
    self.detailListSir = recSirArrayTemp;
    
   
    
    
    
    

    
    
    NSMutableArray *recIngrArrayTemp = [[NSMutableArray alloc] init];
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `raw_material`, `kg`, `raw_prop`, (SELECT `price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as price, (SELECT `user_price` FROM `ingredients` WHERE ingredients.ingredient=products_info.raw_material LIMIT 1) as user_price  FROM products_info WHERE product_list_name='%@' and `type`='2'", [[MySingleton sharedManager] selected_recept_name]]];
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
        
        if(![[fResult stringForColumnIndex:4]  isEqual: @"0"])
        {
            recIngrInfo.price = [fResult stringForColumnIndex:4];
            count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:4];
        }
        else
        {
            recIngrInfo.price = [fResult stringForColumnIndex:3];
            count_sum_price += [fResult doubleForColumnIndex:1]*[fResult doubleForColumnIndex:3];
        }
        
        
        [recIngrArrayTemp addObject:recIngrInfo];
        //NSLog(@"%@", productsArray);
        
    }
    
    
    
   
    
    
    
    
    
    self.detailListIngr = recIngrArrayTemp;
    
    
    for (RecSirIngrInfo *cell in self.detailListSir) {
        count_vklad += [cell.kg doubleValue]*[cell.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg;
    }
    for (RecSirIngrInfo *cell in self.detailListIngr) {
        count_vklad += [cell.kg doubleValue]*[cell.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg;
    }
    
    [fResult close];
    
       
      
    
   }];
    
    
     [self buildSlider];
    
    
    
   
    
}

- (void)buildSlider
{
    [photo removeAllObjects];
    [photos_can_del removeAllObjects];
    
    
    
    
   
    
    
    
    
    if(totalofflinewebCount < totalonlinewebCount)
    {
        showwebbtn.hidden = NO;
    }
    else
    {
        showwebbtn.hidden = YES;
    }
    
    
    
    
    [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *fResult2 = nil;
        
        fResult2 = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM imgs WHERE `rec_name`='%@' ORDER BY `type` DESC, `id` DESC", [[MySingleton sharedManager] selected_recept_name]]];
        
        
        
        while([fResult2 next])
        {
            NSString *temp_img_path = [fResult2 stringForColumnIndex:3];
            NSString *temp_img_type = [fResult2 stringForColumnIndex:2];
            
            
            
            UIImage* img = [UIImage imageWithContentsOfFile:temp_img_path];
            
            
            if(img!=nil)
            {
                [photo addObject:img];
                if([temp_img_type isEqual:@"2"])
                {
                    [photos_can_del addObject:[@([photo count]) stringValue]];
                }
            }
            else if(img==nil && [temp_img_type isEqual:@"1"])
            {
                showwebbtn.hidden = NO;
            }
            else if(img==nil && [temp_img_type isEqual:@"2"])
            {
                //NSLog(@"test");
                
                
                [db executeUpdate:@"DELETE FROM imgs WHERE `rec_name`=? and `name`=?", [[MySingleton sharedManager] selected_recept_name], temp_img_path];
                
                
            }
            
            
        }
        [fResult2 close];
    }];
    
    
    
    
    
    
    [photos_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [sliderView setNeedsLayout];
    [sliderView layoutIfNeeded];
    
    if([photo count] > 0)
    {
        
        
        CGRect newFrame = sliderView.frame;
        newFrame.size.height = 300;
        [sliderView setFrame:newFrame];
        [self.tableView setTableHeaderView:sliderView];
        
        [photos_scrollView setNeedsLayout];
        [photos_scrollView layoutIfNeeded];
        
        photos_scrollView.backgroundColor = [UIColor clearColor];
        photos_scrollView.indicatorStyle = UIScrollViewIndicatorStyleBlack; //Scroll bar style
        photos_scrollView.showsHorizontalScrollIndicator = NO;
        [photos_scrollView setDelegate:self];
        photos_scrollView.showsVerticalScrollIndicator = YES; //Close vertical scroll bar
        photos_scrollView.bounces = YES; //Cancel rebound effect
        photos_scrollView.pagingEnabled = YES; //Flat screen
        
        photos_pagecontrol.numberOfPages = photo.count == 1 ? 0 : photo.count;
        //photos_pagecontrol.currentPage = 0;
        
        
        for(int i = 0; i < photo.count; i++)
        {
            CGRect frame;
            
            
            frame.origin.x = ((photos_scrollView.frame.size.width + 0) *i);
            
            frame.origin.y = 0;
            frame.size = CGSizeMake(photos_scrollView.frame.size.width, photos_scrollView.frame.size.height);
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.clipsToBounds = YES;
            
            
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            [imageView setImage:[photo objectAtIndex:i]];
            
            
            
            [photos_scrollView addSubview:imageView];
            
        }
        
        photos_scrollView.contentSize = CGSizeMake(photos_scrollView.frame.size.width*photo.count, photos_scrollView.frame.size.height);
        
        
        
    }
    else
    {
        CGRect newFrame = sliderView.frame;
        newFrame.size.height = 90;
        [sliderView setFrame:newFrame];
        [self.tableView setTableHeaderView:sliderView];
    }
    
    if([photos_can_del containsObject: [@(photos_pagecontrol.currentPage+1) stringValue]])
    {
        [self showDelBut];
    }
    else
    {
        [self hideDelBut];
    }
    
    

}
- (void)hideDelBut
{
   
    delbut.hidden = YES;
}
- (void)showDelBut
{
    
    delbut.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setToolbarHidden:YES animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
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
        return 4;
    }
    return 0;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    CGFloat pageWidth = photos_scrollView.frame.size.width;
    
    //       //int page = floor((scrollView.contentOffset.x - pageWidth*0.3) / pageWidth) + 1);
    
    
    photos_pagecontrol.currentPage = (int)photos_scrollView.contentOffset.x / (int)pageWidth;
    
    if([photos_can_del containsObject: [@(photos_pagecontrol.currentPage+1) stringValue]])
    {
        [self showDelBut];
    }
    else
    {
        [self hideDelBut];
    }
    //NSLog(@"CURRENT PAGE %ld", (long)photos_pagecontrol.currentPage);
}

- (IBAction)showwebbtn:(id)sender
{
    
    showwebbtn.hidden = YES;
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Загрузка изображений...";
    hud.dimBackground = YES;
    __block NSError* error = nil;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        
        
        
        __block int totalonlinewebCount;
       
        __block int rec_id;
        
      [queue inDatabase:^(FMDatabase *db) {
        
        FMResultSet *fResult = nil;
        
        [db executeUpdate:@"DELETE FROM imgs WHERE `rec_name`=? and `type`='1'", [[MySingleton sharedManager] selected_recept_name]];
        
        fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `imgs` FROM products WHERE `Ссылка`='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
        [fResult next];
         totalonlinewebCount = [fResult intForColumnIndex:1];
        rec_id = [fResult intForColumnIndex:0];
        [fResult close];
      }];
        totalofflinewebCount=0;
        for(int i = 1;i <= totalonlinewebCount;i++)
        {
            NSString *file_name = [NSString stringWithFormat:@"%d-%d.jpg",rec_id,i];
            NSString *url_str = [NSString stringWithFormat:@"%@/rec_images/%@", [[MySingleton sharedManager] url_site],file_name];
            NSURL* url = [NSURL URLWithString:url_str];
            
            
            
            NSData* data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            if(data==nil)
            {
                file_name = [NSString stringWithFormat:@"%d-%d.png",rec_id,i];
                url_str = [NSString stringWithFormat:@"%@/rec_images/%@", [[MySingleton sharedManager] url_site],file_name];
                url = [NSURL URLWithString:url_str];
                data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
            }
            if(data!=nil)
            {
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
                NSString* fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file_name];
               [queue inDatabase:^(FMDatabase *db) {
                [db executeUpdate:@"INSERT INTO imgs VALUES (null,?,1,?)", [[MySingleton sharedManager] selected_recept_name], fullPath];
               }];
                error = nil;
                [data writeToFile:fullPath atomically:YES];
                totalofflinewebCount++;
            }
            
        }
        
        
        
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
           
            [self buildSlider];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (error) {
                
               
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка загрузки изображения"
                                                                message:@"Не удалось загрузить файл."
                                                               delegate:nil
                                                      cancelButtonTitle:@"Закрыть"
                                                      otherButtonTitles:nil];
                [alert show];
            }
            
        });
    });
    
    
   
    
}
- (IBAction)addimgbtn:(id)sender
{
    
    
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Добавить фото рецептуры"
                                                             delegate:(id)self
                                                    cancelButtonTitle:@"Отмена"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles:@"Камера", @"Фотоальбом", nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
    actionSheet.tag = 100;
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    //[actionSheet dismissWithClickedButtonIndex:buttonIndex animated:NO];
    if (actionSheet.tag == 100) {
        //NSLog(@"The Normal action sheet.");
        if(buttonIndex==0)
        {
            //camera
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)self;
            picker.allowsEditing = NO;//ramka show
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self presentViewController:picker animated:YES completion:NULL];
                }];
                
            }
            else{
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            
            
        }
        else if(buttonIndex==1)
        {
            //photoalbum
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = (id)self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
            {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    [self presentViewController:picker animated:YES completion:NULL];
                }];
                
            }
            else{
                
                [self presentViewController:picker animated:YES completion:NULL];
            }
            
           
        }
    }
    else if (actionSheet.tag == 200){
        if(buttonIndex==0)
        {
            //del image
           
            
            
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeIndeterminate;
            hud.labelText = @"Удаление изображения...";
            hud.dimBackground = YES;
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                
                [queue inDatabase:^(FMDatabase *db) {
                    
                    FMResultSet *fResult = nil;
                    
                    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `id`,`name` FROM imgs WHERE `rec_name`='%@' ORDER BY `type` DESC, `id` DESC limit %@,1", [[MySingleton sharedManager] selected_recept_name], [@(photos_pagecontrol.currentPage) stringValue]]];
                    [fResult next];
                    
                    NSString *temp_img_id = [fResult stringForColumnIndex:0];
                    NSString *temp_img_path = [fResult stringForColumnIndex:1];
                    [fResult close];
                    NSLog(@"%@",temp_img_id);
                    [db executeUpdate:@"DELETE FROM imgs WHERE `id`=?", temp_img_id];
            
                    [[NSFileManager defaultManager]removeItemAtPath:temp_img_path error:nil];
                    
                    
                }];
               
                
                
                
               
                
                
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    photos_pagecontrol.currentPage = photos_pagecontrol.currentPage == 0 ? 0 : photos_pagecontrol.currentPage--;
                    
                    [self buildSlider];
                    
                    [self refreshcurrentPage];
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    
                    
                });
            });
            
        }
        
    }
    
   // NSLog(@"Index = %ld - Title = %@", (long)buttonIndex, [actionSheet buttonTitleAtIndex:buttonIndex]);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
     [picker dismissViewControllerAnimated:YES completion:NULL];
    
    
    showwebbtn.hidden = YES;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Обработка...";
    hud.dimBackground = YES;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
   
    
    
    
        
    if ([picker sourceType] == UIImagePickerControllerSourceTypeCamera) {
        
        __block int rec_id;
        __block int count_all_images;
        
        [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *fResult = nil;
        
        
        fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `imgs` FROM products WHERE `Ссылка`='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
        [fResult next];
        rec_id = [fResult intForColumnIndex:0];
        
        fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT count(*) FROM imgs WHERE `rec_name`='%@' and `type`='2'", [[MySingleton sharedManager] selected_recept_name]]];
        [fResult next];
        count_all_images = [fResult intForColumnIndex:0];
            [fResult close];
        }];
        
        
        NSString *file_name = [NSString stringWithFormat:@"offline-%d-%d.jpg",rec_id,count_all_images++];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString* fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file_name];
        
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation (image, 0.3);
        
        [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO imgs VALUES (null,?,2,?)", [[MySingleton sharedManager] selected_recept_name], fullPath];
        }];
        
        [data writeToFile:fullPath  atomically:YES];
        
        
         
        
        
    } else {
        //NSLog(@"info: library");
        
        
        __block int rec_id;
        __block int count_all_images;
        
        [queue inDatabase:^(FMDatabase *db) {
        FMResultSet *fResult = nil;
        
        
        fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `id`, `imgs` FROM products WHERE `Ссылка`='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
        [fResult next];
        rec_id = [fResult intForColumnIndex:0];
        
        fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT count(*) FROM imgs WHERE `rec_name`='%@' and `type`='2'", [[MySingleton sharedManager] selected_recept_name]]];
        [fResult next];
        count_all_images = [fResult intForColumnIndex:0];
            [fResult close];
        }];
        
        NSString *file_name = [NSString stringWithFormat:@"offline-%d-%d.jpg",rec_id,count_all_images++];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString* fullPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:file_name];
        
        UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSData *data = UIImageJPEGRepresentation (image, 0.3);
        
      [queue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"INSERT INTO imgs VALUES (null,?,2,?)", [[MySingleton sharedManager] selected_recept_name], fullPath];
      }];
        
        [data writeToFile:fullPath  atomically:YES];
        
      
        
        
        
        
        
        
    }
     sleep(1);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self buildSlider];
            photos_pagecontrol.currentPage = 0;
            [self refreshcurrentPage];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });

    
    
    
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
   
    
}
- (IBAction)delimgbtn:(id)sender
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Удалить фото рецептуры?"
                                                             delegate:(id)self
                                                    cancelButtonTitle:@"Отмена"
                                               destructiveButtonTitle: nil
                                                    otherButtonTitles:@"Удалить", nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // In this case the device is an iPad.
        [actionSheet showFromRect:[(UIButton *)sender frame] inView:self.view animated:YES];
    }
    else{
        // In this case the device is an iPhone/iPod Touch.
        [actionSheet showInView:self.view];
    }
    actionSheet.tag = 200;
}
- (IBAction)changePage:(id)sender {
    UIPageControl *pager=sender;
    NSInteger page = pager.currentPage;
    CGRect frame = photos_scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [photos_scrollView scrollRectToVisible:frame animated:YES];
}
- (void)refreshcurrentPage {
   
    NSInteger page = photos_pagecontrol.currentPage;
    CGRect frame = photos_scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [photos_scrollView scrollRectToVisible:frame animated:YES];
    if([photos_can_del containsObject: [@(photos_pagecontrol.currentPage+1) stringValue]])
    {
        [self showDelBut];
    }
    else
    {
        [self hideDelBut];
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = nil;
    threecolTableViewCell *cell1 = nil;
    if(indexPath.section==0) {
        
       
        if(indexPath.row==0){
            cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
            cell.textLabel.text = @"Примерная стоимость 1 кг.";
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%.02f руб.", (count_sum_price/count_kg)];
        }
        else if(indexPath.row==1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
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
            cell1.header4.text = @"Цена за кг.";
            cell1.header5.text = @"В фарше";
            cell1.header6.text = @"В готовом продукте";
            return cell1;
        }
        else if(indexPath.row>0) {
            RecSirIngrInfo *recInf = self.detailListSir[indexPath.row-1];
            
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellRows" forIndexPath:indexPath];
            cell1.header1.text = recInf.material;
            cell1.header2.text = [NSString stringWithFormat:@"%g", [recInf.kg doubleValue]];//[@([recInf.kg doubleValue]) stringValue];
            cell1.header3.text = [NSString stringWithFormat:@"%g", [recInf.prop doubleValue]];//[@([recInf.prop doubleValue]) stringValue];
            cell1.header7.text = [@([recInf.price doubleValue]) stringValue];
            cell1.header7.tag = indexPath.row-1;
           
            [cell1.header7 addTarget:self
                              action:@selector(countMoney:)
                    forControlEvents:UIControlEventEditingChanged];
            cell1.header8.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/count_kg] doubleValue]];
            cell1.header9.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg] doubleValue]];
            
            
            
            return cell1;
           
        }
    }
    else if(indexPath.section==2) {
        
        if(indexPath.row==0){
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
            cell1.header1.text = @"Ингредиенты";
            cell1.header2.text = [NSString stringWithFormat:@"%.02f кг", count_kg_ingr];//[NSString stringWithFormat:@"%@ кг", [@(count_kg_ingr) stringValue]];
            cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop_ingr];//[NSString stringWithFormat:@"%@%%", [@(count_prop_ingr) stringValue]];
            cell1.header4.text = @"Цена за кг.";
            cell1.header5.text = @"В фарше";
            cell1.header6.text = @"В готовом продукте";
            return cell1;
        }
        else if(indexPath.row>0) {
            
            
            RecSirIngrInfo *recInf = self.detailListIngr[indexPath.row-1];
            
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellRows" forIndexPath:indexPath];
            cell1.header1.text = recInf.material;
            cell1.header2.text = [NSString stringWithFormat:@"%g", [recInf.kg doubleValue]];//[@([recInf.kg doubleValue]) stringValue];
            cell1.header3.text = [NSString stringWithFormat:@"%g", [recInf.prop doubleValue]];//[@([recInf.prop doubleValue]) stringValue];
            cell1.header7.text = [@([recInf.price doubleValue]) stringValue];
            cell1.header7.tag = indexPath.row-1+100;
           
            [cell1.header7 addTarget:self
                              action:@selector(countMoney:)
                    forControlEvents:UIControlEventEditingChanged];
            cell1.header8.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/count_kg] doubleValue]];
            cell1.header9.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg] doubleValue]];
            return cell1;

        }
    }
    else if(indexPath.section==3) {
        
        if(indexPath.row==0){
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader" forIndexPath:indexPath];
            cell1.header1.text = @"Общее кол-во";
            cell1.header2.text = [NSString stringWithFormat:@"%.02f кг", count_kg];
            cell1.header3.text = [NSString stringWithFormat:@"%.02f%%", count_prop];
            cell1.header4.text = @"";
            cell1.header5.text = @"";
            cell1.header6.text = @"";
            return cell1;
        }
        else if(indexPath.row==1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
            cell.textLabel.text = @"Потери";
            
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%d",[poteri_rec intValue]];
            return cell;
        }
        else if(indexPath.row==2) {
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader2" forIndexPath:indexPath];
            cell1.header1.text = @"Итого цена 1 кг. фарша";
            cell1.header3.text = [NSString stringWithFormat:@"%.02f руб.", count_sum_price/count_kg];
            return cell1;
        }
        else if(indexPath.row==3) {
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"CellHeader2" forIndexPath:indexPath];
            cell1.header1.text = @"Итого цена 1 кг. продукта";
            cell1.header3.text = [NSString stringWithFormat:@"%.02f руб.", count_vklad];
            return cell1;
        }
    }

    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"recPrice" forIndexPath:indexPath];
    }
   
    
   
    
    return cell;
  
}

- (void)countMoney:(UITextField *)theTextField {
    
    // Dispose of any resources that can be recreated.
    count_sum_price = 0.0;
    count_vklad = 0.0;
    
    RecSirIngrInfo *recInf;
    NSIndexPath *indexPath;
   
    
    if(theTextField.tag >= 100)
    {
        recInf = self.detailListIngr[theTextField.tag-100];
        indexPath = [NSIndexPath indexPathForRow:theTextField.tag-100+1 inSection:2];
    }
    else
    {
        recInf = self.detailListSir[theTextField.tag];
        indexPath = [NSIndexPath indexPathForRow:theTextField.tag+1 inSection:1];
    }
    
    recInf.price = theTextField.text;
    
    
    
    NSString *sql = [NSString stringWithFormat:@"UPDATE ingredients SET `user_price`='%@' WHERE `ingredient`='%@';", theTextField.text, recInf.material];
    [queue inDatabase:^(FMDatabase *db) {
    [db executeStatements:sql];
    }];
    
    
    for (RecSirIngrInfo *cell in self.detailListIngr) {
        count_sum_price += [cell.kg doubleValue]*[cell.price doubleValue];
        count_vklad += [cell.kg doubleValue]*[cell.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg;
    }
    for (RecSirIngrInfo *cell in self.detailListSir) {
        count_sum_price += [cell.kg doubleValue]*[cell.price doubleValue];
        count_vklad += [cell.kg doubleValue]*[cell.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg;
    }
    
    
   
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:[NSIndexPath indexPathForRow:2 inSection:3], [NSIndexPath indexPathForRow:3 inSection:3], nil];
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
   
    threecolTableViewCell *cell1 = (threecolTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    cell1.header8.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/count_kg] doubleValue]];
    cell1.header9.text = [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg] doubleValue]];
    
    
}
- (UITextField*)childrenCellFor:(UIView*)view
{
    if (!view)
        return nil;
    if ([view isKindOfClass:[UITableViewCell class]])
        return (UITextField*)view;
    return [self childrenCellFor:view.superview];
}
- (NSString*)doHtml {
    
    
   /*
    [queue inDatabase:^(FMDatabase *db) {
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    }];
    */
    
    NSString* markupText =[NSString stringWithFormat:@"<html><head><meta charset=\"UTF-8\"><style>table, th, td{border: 1px solid #6e6e6e;}</style></head><body><h1>%@</h1>"
                           "<h3>Оболочка: %@</h3><table width=\"100%%\" border=\"0\"><tbody><tr><th style=\"text-align:left;width:30%%\">Сырье</th><th style=\"text-align:right;width:15%%\">"
                           "%.02f кг</th><th style=\"text-align:right\">%.02f%%</th><th style=\"text-align:right\">Цена за кг.</th><th style=\"text-align:right\">В фарше</th><th style=\"text-align:right\">В готовом продукте</th></tr>",[[MySingleton sharedManager] current_recept_name] ,obolochka_rec, count_kg_sir, count_prop_sir];//[fResult stringForColumnIndex:0]
    
    
    for (RecSirIngrInfo *recInf in self.detailListSir) {
        
        markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><td style=\"text-align:left\">%@</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%@</td><td style=\"text-align:right\">%@</td></tr>",recInf.material ,[recInf.kg doubleValue], [recInf.prop doubleValue], [recInf.price doubleValue], [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/count_kg] doubleValue]], [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg] doubleValue]]]];
    }
    
    markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"</tbody></table><br/><br/><table width=\"100%%\" border=\"0\"><tbody><tr><th style=\"text-align:left;width:30%%\">Ингредиенты</th><th style=\"text-align:right;width:15%%\">%.02f кг</th><th style=\"text-align:right\">%.02f%%</th><th style=\"text-align:right\">Цена за кг.</th><th style=\"text-align:right\">В фарше</th><th style=\"text-align:right\">В готовом продукте</th></tr>",count_kg_ingr ,count_prop_ingr]];
    
    for (RecSirIngrInfo *recInf in self.detailListIngr) {
        
        markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><td style=\"text-align:left\">%@</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%g</td><td style=\"text-align:right\">%@</td><td style=\"text-align:right\">%@</td></tr>",recInf.material ,[recInf.kg doubleValue], [recInf.prop doubleValue], [recInf.price doubleValue], [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/count_kg] doubleValue]], [NSString stringWithFormat:@"%g", [[NSString stringWithFormat:@"%.2f", [recInf.kg doubleValue]*[recInf.price doubleValue]/(1-[poteri_rec doubleValue]/100)/count_kg] doubleValue]]]];
    }
    
    markupText = [markupText stringByAppendingString:[NSString stringWithFormat:@"<tr><th style=\"text-align:right;width:30%%\">Итого цена 1 кг. фарша</th><th colspan=\"5\" style=\"text-align:right\">%@</th></tr><tr><th style=\"text-align:right;width:30%%\">Итого цена 1 кг. продукта</th><th colspan=\"5\" style=\"text-align:right\">%@</th></tr></tbody></table><h3>Потери: %@</h3></body></html>",[NSString stringWithFormat:@"%.02f руб.", count_sum_price/count_kg], [NSString stringWithFormat:@"%.02f руб.", count_vklad],[NSString stringWithFormat:@"%d",[poteri_rec intValue]]]];
    
    return markupText;
    
}
- (IBAction)sendemail:(id)sender {
    
    [self doLog:[NSString stringWithFormat:@"Отправка деталей рецептуры %@ на email через iOS", [[MySingleton sharedManager] current_recept_name]]];
    
    
    /*
    [queue inDatabase:^(FMDatabase *db) {
    FMResultSet *fResult = nil;
    
    fResult = [db executeQuery:[NSString stringWithFormat:@"SELECT `product_name` FROM products_info WHERE product_list_name='%@' LIMIT 1", [[MySingleton sharedManager] selected_recept_name]]];
    
    [fResult next];
    }];
    */
    
    NSString *emailTitle = [NSString stringWithFormat:@"Детали рецептуры %@",[[MySingleton sharedManager] current_recept_name]];//!!!!!
    
    
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


@end
