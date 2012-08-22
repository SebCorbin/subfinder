//
//  BetaseriesService.m
//  SubFinder
//
//  Created by sebcorbin on 12/31/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BetaseriesService.h";
#import "HTMLParser.h"
#import "SubSource.h"
#import "ServicesController.h"

@implementation BetaseriesService

+ (NSString *)serviceName {
    return @"Betaseries";
}

+ (NSString *)serviceHost {
    return @"http://www.betaseries.com";
}


- (NSMutableArray *)searchSubtitlesForSubFile:(id)file {
    // Initialization
    file = (SubFileShow *) file;
    NSMutableArray *subtitles = [[NSMutableArray array] autorelease];

    NSString *language = [BetaseriesService getLanguageFromKey:[ServicesController getCurrentLanguageKey]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.betaseries.com/subtitles/show.xml?file=%@&key=%@&language=%@",
                                                                 [file filename],
                                                                 @"01d9224c4fd8", // API Key for BetaSeries
                                                                 language]];
    NSString *content = [ServicesController getContentFromUrl:url];
    HTMLNode *doc = [[HTMLParser parseWithString:content] body];
    for (HTMLNode *subtitle in [doc findChildTags:@"subtitle"]) {
        NSString *subTeamsString = [NSString stringWithFormat:@"Source: %@, quality: %@", [[subtitle findChildTag:@"source"] contents],
                                                              [[subtitle findChildTag:@"quality"] contents]];
        NSString *link = [[subtitle findChildTag:@"url"] contents];
        SubSource *subSource = [[[SubSource alloc] initWithSource:[self class] link:[NSURL URLWithString:link] file:file
                                                             team:subTeamsString hearing:nil] autorelease];
        [subtitles addObject:subSource];
    }

    return subtitles;
}

+ (void)downloadSubtitleForSource:(SubSource *)source {
    NSURLRequest *query = [NSURLRequest requestWithURL:[source link] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];

    // Unzip
    if ([[response MIMEType] isEqualToString:@"application/zip"]) {
        NSURL *zipUrl = [ServicesController getDestinationUrlForSource:source orResponse:response withExtension:@"zip"];
        [ServicesController extractZipData:data atUrl:zipUrl];
    }
    else {
        NSError *writeError;
        NSURL *srtUrl = [ServicesController getDestinationUrlForSource:source orResponse:response withExtension:@"srt"];
        if (![data writeToURL:srtUrl options:YES error:&writeError]) {
            //[Logger log:@"Erreur lors de l'enregistrement du fichier: %@", error];
        }
    }
}

+ (BOOL)handlesMovies {
    return NO;
}

+ (NSArray *)handleLanguages {
    return [NSArray arrayWithObjects:@"en", @"fr", nil];
}

+ (BOOL)handlesShows {
    return YES;
}

+ (NSString *)getLanguageFromKey:(NSString *)key {
    return [[NSDictionary dictionaryWithObjectsAndKeys:
            @"VO", @"en",
            @"VF", @"fr",
            nil] objectForKey:key];
}

@end
