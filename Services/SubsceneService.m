//
//  Created by sebastien on 07/01/12.
//

#import "SubsceneService.h"
#import "ServicesController.h"


@implementation SubsceneService

- (NSMutableArray *)searchSubtitlesForSubFile:(id)file {
    // Initialization
    NSMutableArray *subtitles = [[[NSMutableArray alloc] init] autorelease];

    // Get the episode URL
    NSString *url = [NSString stringWithFormat:@"%@/filmsearch.aspx?q=%@", [SubsceneService serviceHost], [[file movie]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *movieList = [ServicesController getContentFromUrl:[NSURL URLWithString:url]];

    // Parse the content of the movie list
    HTMLParser *parser = [[[HTMLParser alloc] initWithString:movieList error:nil] autorelease];
    HTMLNode *node = [parser body];
    NSString *subList = nil;

    if ([node findChildWithAttribute:@"id" matchingName:@"filmSearch" allowPartial:NO]) {
        node = [node findChildWithAttribute:@"id" matchingName:@"filmSearch" allowPartial:NO];
        for (HTMLNode *a in [node findChildTags:@"a"]) {
            NSString *regexExpr = [NSString stringWithFormat:@"%@ [ \\(\\)a-z0-9\\.]*\\(%d\\)", [[file movie] lowercaseString], [file year]];
            RKRegex *regex = [RKRegex regexWithRegexString:regexExpr options:RKCompileCaseless];
            NSString *title = [[a contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([title isMatchedByRegex:regex]) {
                url = [[SubsceneService serviceHost] stringByAppendingString:[a getAttributeNamed:@"href"]];
                subList = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
                parser = [[[HTMLParser alloc] initWithString:subList error:nil] autorelease];
                node = [parser body];
                [Logger log:@"Found %@ by search on subscene: %@", [file movie], url];
                break;
            }
        }
    }
    else {
        [Logger log:@"Found %@ directly on subscene: %@", [file movie], url];
        subList = movieList;
    }
    if (subList) {
        NSString *hearingPref = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"HearingImpaired"];
        NSString *langKey = [[[ServicesController languagesForServices]
                allKeysForObject:[[[NSUserDefaultsController sharedUserDefaultsController] values]
                                         valueForKeyPath:@"Language"]] lastObject];
        HTMLNode *table = [node findChildWithAttribute:@"class" matchingName:@"filmSubtitleList" allowPartial:NO];
        for (HTMLNode *a in [table findChildrenWithAttribute:@"class" matchingName:@"a1" allowPartial:NO]) {
            if ([[[a findChildTag:@"span"] getAttributeNamed:@"class"] isEqualToString:@"r100"] &&
                    [[[a findChildTag:@"span"] allContents] isMatchedByRegex:[SubsceneService getFullLanguageName:langKey]]) {
                NSString *teams = [[[a findChildTags:@"span"] lastObject] contents];
                NSMutableArray *subTeams = [[[teams componentsSeparatedByCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@"- ._"]] mutableCopy] autorelease];
                int prev = [subTeams count];
                [subTeams removeObjectsInArray:[file teams]];
                // We removed teams from the possible subtitle teams, so if same number as previously, teams don't match
                if ([subTeams count] == prev) {
                    continue;
                }

                NSString *link = [[SubsceneService serviceHost] stringByAppendingString:[a getAttributeNamed:@"href"]];
                NSNumber *hearing = [NSNumber numberWithBool:[[[[a parent] parent]
                        findChildrenWithAttribute:@"id" matchingName:@"imgEar" allowPartial:NO] count] > 0];
                if (![hearingPref isEqualToString:@"Whatever"] && [hearing boolValue] != [hearingPref isEqualToString:@"Yes"]) {
                    continue;
                }
                SubSource *subSource = [[[SubSource alloc] initWithSource:[self class] link:[NSURL URLWithString:link]
                                                                     file:file team:teams hearing:hearing] autorelease];
                [subtitles addObject:subSource];
            }
        }
    }
    else {
        [Logger log:@"Could not find %@ in subscene search", [file movie]];
    }

    return subtitles;
}

+ (void)downloadSubtitleForSource:(SubSource *)source {
    NSString *content = [NSString stringWithContentsOfURL:[source link] encoding:NSUTF8StringEncoding error:nil];

    // Parse the content of the subtitle page
    HTMLNode *form = [[[HTMLParser parseWithString:content] body] findChildTag:@"form"];
    NSURL *srtUrl = [NSURL URLWithString:[[SubsceneService serviceHost] stringByAppendingString:
            [[[[form findChildOfClass:@"downloadLink rating100"]
                    getAttributeNamed:@"href"] componentsSeparatedByString:@"\""] objectAtIndex:7]]];
    // Set up a request with the current link as 'Referer'
    NSString *variables = [NSString stringWithFormat:@"subtitleId=%@&filmId=%@&typeId=%@",
                                                     [[form findChildWithAttribute:@"name" matchingName:@"subtitleId" allowPartial:NO] getAttributeNamed:@"value"],
                                                     [[form findChildWithAttribute:@"name" matchingName:@"filmId" allowPartial:NO] getAttributeNamed:@"value"],
                                                     [[form findChildWithAttribute:@"name" matchingName:@"typeId" allowPartial:NO] getAttributeNamed:@"value"]
    ];
    NSData *postVariables = [variables dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:srtUrl];
    [request setHTTPMethod:@"POST"];
    [request setValue:[[source link] absoluteString] forHTTPHeaderField:@"Referer"];
    [request setHTTPBody:postVariables];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:NULL];
    if ([[response MIMEType] isEqualToString:@"application/zip"]) {
        NSURL *zipUrl = [ServicesController getDestinationUrlForSource:source orResponse:response withExtension:@"zip"];
        [ServicesController extractZipData:data atUrl:zipUrl];
    }
    else {
        // Storing .srt
        srtUrl = [ServicesController getDestinationUrlForSource:source orResponse:response withExtension:@"srt"];
        NSError *writeError = nil;
        if (![data writeToURL:srtUrl options:NSDataWritingAtomic error:&writeError]) {
            [[NSAlert alertWithError:writeError] runModal];
        }
    }
}

+ (BOOL)handlesMovies {
    return YES;
}

+ (BOOL)handlesShows {
    return NO;
}

+ (NSArray *)handleLanguages {
    return [NSArray arrayWithObjects:@"en", @"fr", @"de", @"it", @"es", @"pt", nil];
}

+ (NSString *)serviceName {
    return @"Subscene";
}

+ (NSString *)serviceHost {
    return @"http://subscene.com";
}

+ (NSString *)getFullLanguageName:(NSString *)lang {
    return [[NSDictionary dictionaryWithObjectsAndKeys:
            @"English", @"en",
            @"French", @"fr",
            @"German", @"de",
            @"Italian", @"it",
            @"Spanish", @"es",
            @"Portuguese", @"pt",
            nil] objectForKey:lang];
}

@end