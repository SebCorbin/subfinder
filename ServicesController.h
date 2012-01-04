//
//  ServicesController.h
//  SubFinder
//
//  Created by SebCorbin on 01/01/12.
//  Copyright 2012 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServiceProtocol.h"

@interface ServicesController : NSObject {

}

+ (NSArray *)allServices;

+ (NSArray *)chosenServices;

+ (NSDictionary *)languagesForServices;

+ (NSArray *)getServicesForLanguage:(NSString *)lang;


@end
