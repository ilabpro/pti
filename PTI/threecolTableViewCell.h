//
//  threecolTableViewCell.h
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface threecolTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *header1;
@property (weak, nonatomic) IBOutlet UILabel *header2;
@property (weak, nonatomic) IBOutlet UILabel *header3;
@property (weak, nonatomic) IBOutlet UILabel *header4;
@property (weak, nonatomic) IBOutlet UILabel *header5;
@property (weak, nonatomic) IBOutlet UILabel *header6;

@property (weak, nonatomic) IBOutlet UITextField *header7;
@property (weak, nonatomic) IBOutlet UILabel *header8;
@property (weak, nonatomic) IBOutlet UILabel *header9;
@property (weak, nonatomic) IBOutlet UILabel *header10;


@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIButton *showwebbutton;
@property (weak, nonatomic) IBOutlet UIButton *addimagebut;
@property (weak, nonatomic) IBOutlet UIButton *delimagebut;
@property (weak, nonatomic) IBOutlet UIButton *but1;
@property (weak, nonatomic) IBOutlet UIButton *but2;
@property (weak, nonatomic) IBOutlet UIButton *but3;

@end
