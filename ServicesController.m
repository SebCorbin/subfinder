//
//  ServicesController.m
//  SubFinder
//
//  Created by SebCorbin on 01/01/12.
//  Copyright 2012 SebCorbin. All rights reserved.
//

#import "ServicesController.h";

@implementation ServicesController

+ (NSArray *)allServices {
    static NSArray *services = nil;
    if (services == nil) {
        services = [[NSArray alloc] initWithObjects:
                @"Addic7ed",
                @"Betaseries",
                nil];
    }
    return services;
}

+ (NSArray *)chosenServices {
    NSArray *services = [ServicesController allServices];
    NSMutableArray *chosen = [NSMutableArray array];
    NSDictionary *preferences = [[NSUserDefaultsController sharedUserDefaultsController] values];
    for (NSString *service in services) {
        if ([preferences valueForKey:service]) {
            [chosen addObject:service];
        }
    }
    return [NSArray arrayWithArray:chosen];
}

+ (NSDictionary *)languagesForServices {
    return [NSDictionary dictionaryWithObjectsAndKeys:
            NSLocalizedString(@"English", @"English language"),
            @"en",
            NSLocalizedString(@"French", @"French language"),
            @"fr",
            NSLocalizedString(@"German", @"German language"),
            @"de",
            NSLocalizedString(@"Italian", @"Italian language"),
            @"it",
            NSLocalizedString(@"Spanish", @"Spanish language"),
            @"es",
            NSLocalizedString(@"Portuguese", @"Portuguese language"),
            @"pt",
            nil];
}

+ (NSArray *)getServicesForLanguage:(NSString *)lang {
    NSMutableArray *servicesForLanguageReverted = [NSMutableArray array];
    for (NSString *serviceName in [ServicesController allServices]) {
        id service = NSClassFromString([serviceName stringByAppendingString:@"Service"]);
        // Verify if service handles current language
        if ([[service handleLanguages] containsObject:lang]) {
            [servicesForLanguageReverted addObject:service];
        }
    }
    NSArray *servicesForLanguage = [[servicesForLanguageReverted reverseObjectEnumerator] allObjects];
    return servicesForLanguage;
}

@end
