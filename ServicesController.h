//
//  ServicesController.h
//  SubFinder
//
//  Created by SebCorbin on 01/01/12.
//  Copyright 2012 SebCorbin. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ServiceProtocol.h"
#import "SubFinderAppDelegate.h"

@interface ServicesController : NSObject {

}

+ (NSArray *)allServices;

+ (NSArray *)chosenServices;

+ (NSDictionary *)languagesForServices;

+ (NSArray *)getServicesForLanguage:(NSString *)lang;

+ (NSString *)getContentFromUrl:(NSURL *)url;

+ (NSString *)getCurrentLanguageKey;

+ (void)extractZipData:(NSData *)data atUrl:(NSURL *)zipUrl;

+ (NSURL *)getDestinationUrlForSource:(SubSource *)source orResponse:(NSURLResponse *)response withExtension:(NSString *)string;
@end
