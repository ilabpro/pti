//
//  ReceptsInfo.h
//  PTI
//
//  Created by ILAB PRO on 31.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReceptsInfo : NSObject
{
    NSString *recId;
    NSString *recName;
    NSString *recView;
    NSString *recFio;
    NSString *recFioSht;
    NSString *recLink;
}
@property (strong, nonatomic) NSString *recId;
@property (strong, nonatomic) NSString *recName;
@property (strong, nonatomic) NSString *recView;
@property (strong, nonatomic) NSString *recFio;
@property (strong, nonatomic) NSString *recFioSht;
@property (strong, nonatomic) NSString *recLink;
@end
