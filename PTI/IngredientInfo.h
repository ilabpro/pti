//
//  IngredientInfo.h
//  PTI
//
//  Created by ILAB PRO on 30.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IngredientInfo : NSObject
{
    NSString *ingrId;
    NSString *ingrName;
}
@property (strong, nonatomic) NSString *ingrId;
@property (strong, nonatomic) NSString *ingrName;

@end
