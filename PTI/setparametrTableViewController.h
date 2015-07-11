//
//  setparametrTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface setparametrTableViewController : UITableViewController
@property (nonatomic) NSString* parName;
@property (nonatomic, copy) NSArray *varsArray;
@property (nonatomic, copy) NSString *writableDBPath;
@end
