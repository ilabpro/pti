//
//  loginViewController.h
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface loginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) UITextField* activeField;
@property (weak, nonatomic) IBOutlet UITextField *loginText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (nonatomic, copy) MBProgressHUD *hud;
@property (nonatomic, copy) NSMutableData *responseData;
@end
