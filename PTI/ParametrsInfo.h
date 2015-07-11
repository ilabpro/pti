//
//  ParametrsInfo.h
//  PTI
//
//  Created by ILAB PRO on 30.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParametrsInfo : NSObject
{
    NSString *parSel;
    NSString *parName;
}
@property (strong, nonatomic) NSString *parSel;
@property (strong, nonatomic) NSString *parName;
@end
