//
//  searchreceptsTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface searchreceptsTableViewController : UITableViewController
@property (nonatomic, copy) NSArray *receptsArray;
@property (nonatomic, copy) NSString *writableDBPath;
@end
