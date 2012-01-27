//
//  Created by sebastien on 07/01/12.
//
// To change the template use AppCode | Preferences | File Templates.
//


#import "SubsceneService.h"
#import "ServicesController.h"
#import "SubSource.h"


@implementation SubsceneService

- (NSMutableArray *)searchSubtitlesForSubFile:(id)file {
    // Initialization
    NSMutableArray *subtitles = [[NSMutableArray alloc] init];

    // Get the episode URL
    NSString *url = [NSString stringWithFormat:@"%@/filmsearch.aspx?q=%@", [SubsceneService serviceHost], [[file movie]
            stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *movieList = [ServicesController getContentFromUrl:[NSURL URLWithString:url]];

    // Parse the content of the movie list
    HTMLParser *parser = [[[HTMLParser alloc] initWithString:movieList error:nil] autorelease];
    HTMLNode *node = [parser body];
    NSString *subList = nil;

    for (HTMLNode *a in [node findChildrenOfClass:@"popular"]) {
        RKRegex *regex = [RKRegex regexWithRegexString:[NSString stringWithFormat:@"%@ \\(%d\\)",
                                                                                  [[file movie] lowercaseString],
                                                                                  [file year]]
                                               options:RKCompileCaseless];
        NSString *title = [[a contents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([title isMatchedByRegex:regex]) {
            url = [[SubsceneService serviceHost] stringByAppendingString:[a getAttributeNamed:@"href"]];
            subList = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding:NSUTF8StringEncoding error:nil];
            parser = [[[HTMLParser alloc] initWithString:subList error:nil] autorelease];
            node = [parser body];
        }
    }
    if (subList) {
        NSString *langKey = [[[ServicesController languagesForServices]
                allKeysForObject:[[[NSUserDefaultsController sharedUserDefaultsController] values]
                                         valueForKeyPath:@"Language"]] lastObject];
        HTMLNode *table = [node findChildWithAttribute:@"class" matchingName:@"filmSubtitleList" allowPartial:NO];
        for (HTMLNode *a in [table findChildrenWithAttribute:@"class" matchingName:@"a1" allowPartial:NO]) {
            if ([[[a findChildTag:@"span"] getAttributeNamed:@"class"] isEqualToString:@"r100"] &&
                    [[[a findChildTag:@"span"] allContents] isMatchedByRegex:[SubsceneService getFullLanguageName:langKey]]) {
                NSMutableArray *subTeams = [[[NSMutableArray alloc]
                        initWithArray:[[[[a findChildTags:@"span"] lastObject] contents] componentsSeparatedByCharactersInSet:
                                [NSCharacterSet characterSetWithCharactersInString:@"- ._"]]] autorelease];
                int prev = [subTeams count];
                [subTeams removeObjectsInArray:[file teams]];
                // We removed teams from the possible subtitle teams, so if same number as previously, teams don't match
                if ([subTeams count] == prev) {
                    continue;
                }

                NSString *link = [[SubsceneService serviceHost] stringByAppendingString:[a getAttributeNamed:@"href"]];
                NSNumber *hearing = [[NSNumber alloc] initWithBool:
                        [[[[a parent] parent] findChildrenWithAttribute:@"id" matchingName:@"imgEar" allowPartial:NO] count] > 0];
                NSString *team = [[[a findChildTags:@"span"] lastObject] contents];
                SubSource *subSource = [[[SubSource alloc] initWithSource:[self class] link:[[NSURL alloc] initWithString:link]
                                                                     file:file team:team hearing:hearing] autorelease];
                [subtitles addObject:subSource];
            }
        }
    }

    return subtitles;
}

+ (void)downloadSubtitleForSource:(SubSource *)source {
    NSString *content = [NSString stringWithContentsOfURL:[source link] encoding:NSUTF8StringEncoding error:nil];

    // Parse the content of the movie list
    HTMLNode *form = [[[[HTMLParser alloc] initWithString:content error:nil] body] findChildTag:@"form"];
    NSURL *srtUrl = [NSURL URLWithString:[[SubsceneService serviceHost] stringByAppendingString:
            [[[[form findChildOfClass:@"downloadLink rating100"]
                    getAttributeNamed:@"href"] componentsSeparatedByString:@"\""] objectAtIndex:7]]];
    // Set up a request with the current link as 'Referer'
    NSMutableURLRequest *query = [NSMutableURLRequest requestWithURL:srtUrl];
    [query setValue:[[source link] absoluteString] forHTTPHeaderField:@"Referer"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
    // Storing .srt
    if ([[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RenameFile"]) {
        srtUrl = [[[[source originalFile] localUrl] URLByDeletingPathExtension] URLByAppendingPathExtension:@"srt"];
    }
    else {
        srtUrl = [[[[source originalFile] localUrl] URLByDeletingLastPathComponent]
                URLByAppendingPathComponent:[response suggestedFilename]];
    }
    NSError *writeError = nil;
    if (![data writeToURL:srtUrl options:NSDataWritingAtomic error:&writeError]) {
        // @TODO error while writing
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