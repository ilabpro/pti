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
@synthesize url_site;
@synthesize selected_product_name;
@synthesize selected_product_search_type;
@synthesize selected_ingr_name;
@synthesize parametrSetList;
@synthesize selected_recept_name;
@synthesize current_recept_name;
@synthesize selected_producttype_name;

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
        url_site = @"http://protein.ilab.pro";
        selected_product_name = @"";
        selected_producttype_name = @"";
        selected_product_search_type = @"";
        selected_ingr_name = @"";
        parametrSetList = [[NSMutableArray alloc] init];
        selected_recept_name = @"";
        current_recept_name = @"";
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end