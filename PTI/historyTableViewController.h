//
//  historyTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 11.07.15.
//  Copyright © 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface historyTableViewController : UITableViewController
@property (nonatomic, copy) NSArray *receptsArray;
@property (nonatomic, copy) NSString *writableDBPath;
@end
