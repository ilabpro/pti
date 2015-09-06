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
NSString *url_site;
NSString *selected_product_name;
NSString *selected_producttype_name;
NSString *selected_product_search_type;
NSString *selected_ingr_name;
NSMutableArray *parametrSetList;
NSString *selected_recept_name;
NSString *current_recept_name;
}

@property (nonatomic, retain) NSString *url_webservice;
@property (nonatomic, retain) NSString *url_site;
@property (nonatomic, retain) NSString *selected_product_name;
@property (nonatomic, retain) NSString *selected_producttype_name;
@property (nonatomic, retain) NSString *selected_product_search_type;
@property (nonatomic, retain) NSString *selected_ingr_name;
@property (nonatomic, retain) NSMutableArray *parametrSetList;
@property (nonatomic, retain) NSString *selected_recept_name;
@property (nonatomic, retain) NSString *current_recept_name;

+ (id)sharedManager;

@end
