//
//  ingredientTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ingredientTableViewController : UITableViewController
@property (nonatomic, copy) NSArray *ingredientsArray;
@property (nonatomic, copy) NSString *writableDBPath;
@end
