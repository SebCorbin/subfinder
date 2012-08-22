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
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"NoNetworkConnection", @"") defaultButton:@"OK"
                                       alternateButton:nil otherButton:nil informativeTextWithFormat:NSLocalizedString(@"VerifyConnection", @"")];
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

+ (NSString *)getCurrentLanguageKey {
    id values = [[NSUserDefaultsController sharedUserDefaultsController] values];
    return [[[ServicesController languagesForServices] allKeysForObject:[values valueForKeyPath:@"Language"]] lastObject];
}

+ (void)extractZipData:(NSData *)data atUrl:(NSURL *)zipUrl {
    NSError *error = nil;
    if (![data writeToURL:zipUrl options:YES error:&error]) {
        // Error creating zip
        NSLog(@"Error writing zip %@", [error localizedDescription]);
        return;
    }

    NSTask *unzip = [[NSTask alloc] init];
    NSPipe *zipPipe = [NSPipe pipe];
    [unzip setLaunchPath:@"/usr/bin/unzip"];
    [unzip setStandardOutput:zipPipe];
    [unzip setArguments:[NSArray arrayWithObjects:@"-p", [NSString stringWithFormat:@"%@", [zipUrl relativePath]], nil]];
    [unzip launch];

    NSData *zipData = [[zipPipe fileHandleForReading] readDataToEndOfFile];

    NSURL *srtUrl = [[zipUrl URLByDeletingPathExtension] URLByAppendingPathExtension:@"srt"];
    if (![zipData writeToURL:srtUrl options:YES error:&error]) {
        // error creating
        NSLog(@"Error writing srt %@", [error localizedDescription]);
        return;
    }

    [unzip waitUntilExit];
    [unzip release];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm removeItemAtURL:zipUrl error:&error]) {
        // error deleting
        NSLog(@"Error deleting zip %@", [error localizedDescription]);
        return;
    }
    [fm release];
}

+ (NSURL *)getDestinationUrlForSource:(SubSource *)source orResponse:(NSURLResponse *)response withExtension:(NSString *)extension {
    NSURL *url;
    if ([[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RenameFile"] booleanValue]) {
        url = [[[[source originalFile] localUrl] URLByDeletingPathExtension] URLByAppendingPathExtension:extension];
    }
    else {
        url = [[[[source originalFile] localUrl] URLByDeletingLastPathComponent]
                URLByAppendingPathComponent:[response suggestedFilename]];
    }
    return url;
}
@end
