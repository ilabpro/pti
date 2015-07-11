//
//  MySingleton.m
//  PTI
//
//  Created by ILAB PRO on 28.05.15.
//  Copyright (c) 2015 ilab.pro LLC. All rights reserved.
//

#import "MySingleton.h"

@implementation MySingleton

@synthesize url_webservice;
@synthesize someProperty2;
@synthesize someProperty3;
@synthesize someProperty4;
@synthesize someProperty5;
@synthesize someProperty6;



#pragma mark Singleton Methods

+ (id)sharedManager {
    static MySingleton *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        url_webservice = @"http://protein.ilab.pro/ios_webservice.php";
        someProperty2 = @"Default Property Value";
        someProperty3 = @"Default Property Value";
        someProperty4 = @"Default Property Value";
        someProperty5 = @"Default Property Value";
        someProperty6 = @"Default Property Value";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end