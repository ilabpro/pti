//
//  prodtypesTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 11.07.15.
//  Copyright © 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface prodtypesTableViewController : UITableViewController
@property (nonatomic, copy) NSArray *productsArray;
@property (nonatomic, copy) NSString *writableDBPath;
@end
