//
//  Created by sebastien on 29/12/11.
//

#import "Addic7edService.h"
#import "SubSource.h"
#import "ServicesController.h"

@implementation Addic7edService

+ (NSString *)serviceName {
    return @"Addic7ed";
}

+ (NSString *)serviceHost {
    return @"http://www.addic7ed.com";
}

+ (NSArray *)handleLanguages {
    return [NSArray arrayWithObjects:@"en", @"fr", @"de", @"it", @"es", @"pt", nil];
}

+ (NSString *)releasePattern {
    return @" \nVersion (?P<subteams>.+), ([0-9]+).([0-9])+ MBs";
}

- (NSMutableArray *)searchSubtitlesForSubFile:(id)file {
    // Initialization
    file = (SubFileShow *) file;
    NSMutableArray *subtitles = [NSMutableArray array];

    // Get the episode URL
    NSString *name = [[[file show] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *query = [NSString stringWithFormat:@"%@/serie/%@/%@/%@/%@", [Addic7edService serviceHost], name,
                                                 [file season], [file episode], name];
    NSString *content = [ServicesController getContentFromUrl:[NSURL URLWithString:query]];

    // Parse the content of the episode page
    HTMLParser *parser = [[[HTMLParser alloc] initWithString:content error:nil] autorelease];
    HTMLNode *node = [parser body];

    // Get the potential sub-teams
    NSMutableArray *teams = [NSMutableArray arrayWithArray:[[[file teams]
            componentsJoinedByString:@"-"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"- ._"]]];

    NSString *hearingPref = [[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"HearingImpaired"];

    for (HTMLNode *td in [node findChildrenWithAttribute:@"class" matchingName:@"NewsTitle" allowPartial:NO]) {
        // Verify the release pattern
        NSString *subTeamsString = nil;
        if (![[td allContents] getCapturesWithRegexAndReferences:[Addic7edService releasePattern], @"${subteams}", &subTeamsString, nil]) {
            continue;
        }

        HTMLNode *table = [[td parent] parent];

        // Verify the teams
        NSMutableArray *subTeams = [[[NSMutableArray alloc]
                initWithArray:[subTeamsString componentsSeparatedByCharactersInSet:
                        [NSCharacterSet characterSetWithCharactersInString:@"- ._"]]] autorelease];
        [subTeams removeObjectsInArray:teams];
        // We removed all file teams from the possible subtitle teams, so if anymore, teams don't match
        if ([subTeams count]) {
            continue;
        }

        // Get language
        NSString *currentLanguage = [Addic7edService getLanguageFromKey:[ServicesController getCurrentLanguageKey]];
        for (HTMLNode *lang in [table findChildrenWithAttribute:@"class" matchingName:@"language" allowPartial:0]) {
            if (![[[lang allContents] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]
                    isMatchedByRegex:currentLanguage]) {
                continue;
            }
            // Verify subtitle status
            if ([[[[lang parent] findChildTag:@"strong"] allContents] isEqualToString:@"Completed"]) {
                continue;
            }
            // Find if there is hearing impaired
            NSNumber *hearing = [NSNumber numberWithBool:NO];
            if ([[[[lang parent] nextNode] findChildrenWithAttribute:@"title" matchingName:@"Hearing Impaired" allowPartial:NO] count]) {
                hearing = [NSNumber numberWithBool:YES];
            }
            if (![hearingPref isEqualToString:@"Whatever"] && [hearing boolValue] != [hearingPref isEqualToString:@"Yes"]) {
                continue;
            }

            // Subtitle found
            HTMLNode *tdSubtitle = [[lang parent] findChildWithAttribute:@"colspan" matchingName:@"3" allowPartial:0];
            NSString *link = [NSString stringWithFormat:@"http://www.addic7ed.com%@", [[[tdSubtitle findChildTags:@"a"] lastObject] getAttributeNamed:@"href"]];
            SubSource *subSource = [[[SubSource alloc] initWithSource:[self class] link:[NSURL URLWithString:link] file:file
                                                                 team:subTeamsString hearing:hearing] autorelease];
            [subtitles addObject:subSource];
        }
    }

    return subtitles;
}

+ (void)downloadSubtitleForSource:(SubSource *)source {
    // Modifying headers to get the .srt file
    NSMutableURLRequest *query = [[NSURLRequest requestWithURL:[source link] cachePolicy:NSURLRequestUseProtocolCachePolicy
                                               timeoutInterval:60.0] mutableCopy];
    [query setValue:[[source link] absoluteString] forHTTPHeaderField:@"Referer"];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
    if ([[response suggestedFilename] isEqualToString:@"downloadexceeded.php.html"]) {
        [Logger log:@"Too many downloads from Addic7ed for today"];
    }
    else {
        // Storing .srt
        NSURL *srtUrl;
        if ([[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"RenameFile"]) {
            srtUrl = [[[[source originalFile] localUrl] URLByDeletingPathExtension] URLByAppendingPathExtension:@"srt"];
        }
        else {
            srtUrl = [[[[source originalFile] localUrl] URLByDeletingLastPathComponent]
                    URLByAppendingPathComponent:[response suggestedFilename]];
        }
        NSError *writeError = nil;
        if (![data writeToURL:srtUrl options:NSDataWritingAtomic error:&writeError]) {
            [[NSAlert alertWithError:writeError] runModal];
        }
    }
    [query release];
}

+ (NSString *)getLanguageFromKey:(NSString *)key {
    return [[NSDictionary dictionaryWithObjectsAndKeys:
            @"English", @"en",
            @"French", @"fr",
            @"German", @"de",
            @"Italian", @"it",
            @"Spanish", @"es",
            @"Portuguese", @"pt",
            nil] objectForKey:key];
}

+ (BOOL)handlesMovies {
    return NO;
}

+ (BOOL)handlesShows {
    return YES;
}

@end