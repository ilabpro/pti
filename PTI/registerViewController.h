//
//  registerViewController.h
//  PTI
//
//  Created by ILAB PRO on 03.06.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface registerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *fio;
@property (weak, nonatomic) IBOutlet UITextField *company;
@property (weak, nonatomic) IBOutlet UITextField *doljnost;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *login;
@property (weak, nonatomic) IBOutlet UITextField *pass_one;
@property (weak, nonatomic) IBOutlet UITextField *pass_two;
@property (nonatomic, copy) MBProgressHUD *hud;
@property (nonatomic, copy) NSMutableData *responseData;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) UITextField* activeField;
@property (nonatomic, copy) UIGestureRecognizer *tapper;
@end
