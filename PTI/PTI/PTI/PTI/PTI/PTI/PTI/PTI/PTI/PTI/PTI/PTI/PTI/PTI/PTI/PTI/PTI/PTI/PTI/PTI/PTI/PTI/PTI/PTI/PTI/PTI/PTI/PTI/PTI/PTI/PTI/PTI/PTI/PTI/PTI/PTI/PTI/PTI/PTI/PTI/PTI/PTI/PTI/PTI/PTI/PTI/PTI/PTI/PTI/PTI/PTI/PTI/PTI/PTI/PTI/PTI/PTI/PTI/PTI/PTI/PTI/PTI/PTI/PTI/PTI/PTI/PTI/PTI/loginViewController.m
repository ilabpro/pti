//
//  loginViewController.m
//  PTI
//
//  Created by ILAB PRO on 27.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "loginViewController.h"
#import "MySingleton.h"

@interface loginViewController ()

@end

@implementation loginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"UserId"];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)tryAuth:(id)sender {
    
    //[[MySingleton sharedManager] setUserID:@"1234"];
    
   
    [[NSUserDefaults standardUserDefaults] setInteger:1234 forKey:@"UserId"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:@"goproducts" sender:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
