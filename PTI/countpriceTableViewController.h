//
//  countpriceTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 01.06.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface countpriceTableViewController : UITableViewController<UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) NSArray *detailListIngr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *print_but;
@property (nonatomic, copy) NSString *writableDBPath;
@end
