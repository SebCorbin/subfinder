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
                @"Subscene",
                nil];
    }
    return services;
}

+ (NSArray *)chosenServices {
    NSArray *services = [ServicesController allServices];
    NSMutableArray *chosen = [NSMutableArray array];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    for (NSString *service in services) {
        if ([defaults boolForKey:[@"Service" stringByAppendingString:service]]) {
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

+ (NSString *)getContentFromUrl:(NSURL *)url {
    NSURLRequest *query = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
    NSURLResponse *response = nil;
    NSError **error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:error];
    if (!response) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"NoNetworkConnection", @"No network connection") defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"VerifyConnection", @"Please verify your internet connectivity")];
        [alert beginSheetModalForWindow:[[NSApp delegate] serviceWindow] modalDelegate:[NSApp delegate] didEndSelector:@selector(terminateApp:) contextInfo:nil];
    }
    else {
        // HTTP Status code must be 200
        int statusCode = [(NSHTTPURLResponse *) response statusCode];
        if (statusCode == 404) {
            [Logger log:@"Page %@ returned 404", [url absoluteString]];
        }
        else if (statusCode == 200) {
            return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return nil;
}


@end
