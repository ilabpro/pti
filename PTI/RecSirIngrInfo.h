//
//  RecSirIngrInfo.h
//  PTI
//
//  Created by ILAB PRO on 01.06.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecSirIngrInfo : NSObject
{
    NSString *material;
    NSString *kg;
    NSString *prop;
    NSString *price;
}
@property (strong, nonatomic) NSString *material;
@property (strong, nonatomic) NSString *kg;
@property (strong, nonatomic) NSString *prop;
@property (strong, nonatomic) NSString *price;
@end
