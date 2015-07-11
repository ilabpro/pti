//
//  MySingleton.h
//  PTI
//
//  Created by ILAB PRO on 28.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MySingleton : NSObject {
NSString *url_webservice;
NSString *someProperty2;
NSString *someProperty3;
NSString *someProperty4;
NSString *someProperty5;
NSString *someProperty6;
}

@property (nonatomic, retain) NSString *url_webservice;
@property (nonatomic, retain) NSString *someProperty2;
@property (nonatomic, retain) NSString *someProperty3;
@property (nonatomic, retain) NSString *someProperty4;
@property (nonatomic, retain) NSString *someProperty5;
@property (nonatomic, retain) NSString *someProperty6;

+ (id)sharedManager;

@end
