//
//  detailTableViewController.h
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "MBProgressHUD.h"

@interface detailTableViewController : UITableViewController<UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, copy) NSArray *detailListSir;
@property (nonatomic, copy) NSArray *detailListIngr;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *print_but;
@property (nonatomic, copy) NSString *writableDBPath;
@property (nonatomic, copy) MBProgressHUD *hud;
@property (weak, nonatomic) IBOutlet UIView *sliderView;
@property (weak, nonatomic) IBOutlet UIScrollView *photos_scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *photos_pagecontrol;
@property (weak, nonatomic) IBOutlet UIButton *showwebbtn;
@property (weak, nonatomic) IBOutlet UIButton *delbut;

@end