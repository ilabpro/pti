//
//  ProductInfo.h
//  PTI
//
//  Created by ILAB PRO on 29.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProductInfo : NSObject
{
    NSString *prodId;
    NSString *prodName;
}
@property (strong, nonatomic) NSString *prodId;
@property (strong, nonatomic) NSString *prodName;

@end
