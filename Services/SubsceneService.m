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
    file = (SubFileMovie *) file;
    NSMutableArray *subtitles = [[NSMutableArray array] autorelease];

    // Get the episode URL
    NSString *name = [[[file movie] lowercaseString] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *query = [NSString stringWithFormat:@"%@%@", [SubsceneService serviceHost], name, nil];
    NSURL *searchUrl = [[NSURL alloc] initWithString:query];
    NSString *content = [SubsceneService getContentFromUrl:searchUrl];

    // Parse the content of the episode page
    HTMLParser *parser = [[[HTMLParser alloc] initWithString:content error:nil] autorelease];
    // @TODO handle parsing error
    HTMLNode *node = [parser body];

    NSString *langKey = [[[ServicesController languagesForServices]
            allKeysForObject:[[[NSUserDefaultsController sharedUserDefaultsController] values]
                                     valueForKeyPath:@"Language"]] lastObject];
    for (HTMLNode *a in [node findChildrenWithAttribute:@"class" matchingName:@"a1" allowPartial:NO]) {
        if ([[[a findChildTag:@"span"] allContents] isMatchedByRegex:[SubsceneService getFullLanguageName:langKey]]) {
            NSString *link = [a getAttributeNamed:@"href"];
            // @TODO Get hearing impaired
            SubSource *subSource = [[[SubSource alloc] initWithSource:[self class] link:[[NSURL alloc] initWithString:link] file:file hearing:NULL] autorelease];

        }
    }
}

+ (NSString *)getContentFromUrl:(NSURL *)url {
    NSURLRequest *query = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy
                                       timeoutInterval:60.0];
    NSURLResponse *response = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:query returningResponse:&response error:NULL];
    if (!response) {
        // @TODO Connection failed
    }
    else {
        // HTTP Status code must be 200
        int statusCode = [(NSHTTPURLResponse *) response statusCode];
        if (statusCode == 404) {
            // @TODO Handle 404
        }
        else if (statusCode == 200) {
            return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
        }
    }
    return nil;
}

+ (void)downloadSubtitleForSource:(SubSource *)source {

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
    return @"http://subscene.com/";
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