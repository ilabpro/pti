//
//  forgotViewController.h
//  PTI
//
//  Created by ILAB PRO on 03.06.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface forgotViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *emailText;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) MBProgressHUD *hud;
@property (nonatomic, copy) NSMutableData *responseData;
@property (nonatomic, copy) UITextField* activeField;
@property (nonatomic, copy) UIGestureRecognizer *tapper;
@end
